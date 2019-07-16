FROM inhumantsar/ansible:alpine
MAINTAINER Shaun Martin <shaun@samsite.ca>

ARG VERSION

WORKDIR $WORKDIR

RUN pip install --force-reinstall ansible~="${VERSION}.0"

ONBUILD ADD . $WORKDIR/
ONBUILD RUN /start.sh -y

CMD ["/start.sh", "-x"]
