FROM inhumantsar/ansible:centos7
MAINTAINER Shaun Martin <shaun@samsite.ca>

ENV WORKDIR /workspace
ENV GALAXY $WORKDIR/requirements.yml
ENV PYPI $WORKDIR/requirements.txt
ENV SYSPKGS $WORKDIR/system_packages.txt

WORKDIR $WORKDIR

ONBUILD ADD . $WORKDIR/
ONBUILD RUN /start.sh -y -g $GALAXY -r $PYPI -s $SYSPKGS

CMD ["/start.sh", "-x", "-g", "$GALAXY", "-r", "$PYPI", "-s", "$SYSPKGS"]
