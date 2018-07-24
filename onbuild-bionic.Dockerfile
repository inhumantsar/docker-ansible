FROM inhumantsar/ansible:bionic
MAINTAINER Shaun Martin <shaun@samsite.ca>

ARG VERSION

ENV WORKDIR /workspace
ENV GALAXY $WORKDIR/requirements.yml
ENV PYPI $WORKDIR/requirements.txt
ENV SYSPKGS $WORKDIR/system_packages.txt

WORKDIR $WORKDIR

RUN pip install --force-reinstall ansible~="${VERSION}.0"

ONBUILD ADD . $WORKDIR/
ONBUILD RUN /start.sh -y -g $GALAXY -r $PYPI -s $SYSPKGS

CMD ["/start.sh", "-x", "-g", "$GALAXY", "-r", "$PYPI", "-s", "$SYSPKGS"]
