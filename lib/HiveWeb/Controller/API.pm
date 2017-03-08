package HiveWeb::Controller::API;
use Moose;
use namespace::autoclean;

use JSON::PP;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

HiveWeb::Controller::API - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub has_access :Private
	{
	my $c        = shift;
	my $badge_no = shift;
	my $iname    = shift;
	my $item     = $c->model('DB::Item')->find( { name => $iname } );
	my $badge    = $c->model('DB::Badge')->find( { badge_number => $badge_no } );
	my $member;
	
	if (defined($badge))
		{
		$member = $badge->member();
		}
	else
		{
		$member = $c->model('DB::Member')->find( { accesscard => $badge_no } );
		}
	
	return "Invalid badge"
		if (!defined($member));
	return "Invalid item"
		if (!defined($item));
	return "Locked out"
		if ($member->is_lockedout());
	
	my $access = $member->has_access($item);
	
	# Log the access
	$c->model('DB::AccessLog')->create(
		{
		member_id => $member->member_id(),
		item_id   => $item->item_id(),
		granted   => $access,
		});
	
	return $access ? undef : "Access denied";
	}


sub begin :Private
	{
	my ($self, $c) = @_;

	$c->stash()->{in} = $c->req()->body_data();
	$c->stash()->{out} = {};
	$c->stash()->{view} = $c->view('JSON');
	}

sub end :Private
	{
	my ($self, $c) = @_;

	$c->detach($c->stash()->{view});
	}

sub index :Path :Args(0)
	{
	my ( $self, $c ) = @_;
	
	$c->response->body('Matched HiveWeb::Controller::API in API.');
	}

sub access :Local
	{
	my ($self, $c) = @_;
	my $in     = $c->stash()->{in};
	my $out    = $c->stash()->{out};
	my $device = $c->model('DB::Device')->find({ name => $in->{device} });
	my $data   = $in->{data};
	my $view   = $c->view('ChecksummedJSON');

	if (!defined($device))
		{
		$out->{response} = JSON->false();
		$out->{error} = 'Cannot find device.';
		return;
		}
	
	$c->stash()->{view}   = $view;
	$c->stash()->{device} = $device;
	
	my $shasum = $view->make_hash($c, $data);
	if ($shasum ne uc($in->{checksum}))
		{
		$out->{response} = JSON::PP->false();
		$out->{error} = 'Invalid checksum.';
		return;
		}
	
	$out->{response} = JSON::PP->true();
	my $operation = lc($in->{operation} // 'access');
	if ($operation eq 'access')
		{
		my $badge  = $data->{badge};
		my $item   = $data->{location} // $data->{item};
		my $access = has_access($c, $badge, $item);		
		my $d_i    = $device
			->search_related('device_items')
			->search_related('item', { name => $item } );
		
		if ($d_i->count() < 1)
			{
			$out->{access} = JSON::PP->false();
			$out->{error} = "Device not authorized for " . $item;
			}
		elsif (defined($access))
			{
			$out->{access} = JSON::PP->false();
			$out->{error} = $access;
			}
		else
			{
			$out->{access} = JSON::PP->true();
			}
		}
	else
		{
		$out->{response} = JSON::PP->false();
		$out->{error} = 'Invalid operation.';
		}
	} 

=encoding utf8

=head1 AUTHOR

Greg Arnold

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;