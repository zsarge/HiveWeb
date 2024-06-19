FROM ubuntu:22.04

RUN echo "THIS IS PRIMARILY FOR LOCAL DEVELOPMENT; NOT DEPLOYMENT"

WORKDIR /app

RUN apt-get update

# install all packages listed in README
RUN apt-get update -y && apt-get install -y \
	libbytes-random-secure-perl \
	libcatalyst-action-renderview-perl \
	libcatalyst-authentication-store-dbix-class-perl \
	libcatalyst-plugin-authorization-acl-perl \
	libcatalyst-plugin-configloader-perl \
	libcatalyst-plugin-static-simple-perl \
	libcatalyst-plugin-session-state-cookie-perl \
	libcatalyst-plugin-session-store-dbic-perl \
	libcatalyst-view-json-perl \
	libcatalyst-view-tt-perl \
	libdbix-class-uuidcolumns-perl \
	libdbix-class-inflatecolumn-serializer-perl \
	libdbix-class-deploymenthandler-perl \
	libdbix-class-helpers-perl \
	libcrypt-eksblowfish-perl \
	libdatetime-format-dbi-perl \
	libdatetime-format-iso8601-perl \
	libdbd-pg-perl \
	libemail-mime-perl \
	libjson-perl \
	libmath-round-perl \
	libtext-markdown-perl \
	libpdf-api2-perl \
	libimage-magick-perl \
	libconvert-base32-perl \
	libimager-qrcode-perl \
	libauthen-oath-perl \
	libemail-address-xs-perl \
	cssmin \
	node-less

# Install things not listed in README
RUN apt-get install -y \
	libmodule-install-perl \ 
	make \
	git \
	apache2 \
	libapache2-mod-perl2

# RUN perl Makefile.PL
# RUN make 
# RUN make test # has errors
# RUN make install
# RUN make manifest
# RUN make dist

COPY . .

EXPOSE 3000
EXPOSE 80

ENTRYPOINT /app/script/startup-script.sh

