# Binder (mybinder.org) entry point. Binder uses this file instead of the
# top-level Dockerfile because it sits in binder/.
#
# It starts from the published, frozen GOxploreR image and only adds the
# Jupyter layer Binder needs to serve RStudio in the browser. R and all
# package versions come unchanged from the base image.
#
# Replace shaileshtripathi once, after the image is published and set to public.
# For a fully frozen setup, replace the tag with the digest:
#   FROM ghcr.io/shaileshtripathi/goxplorer@sha256:<digest>
FROM ghcr.io/shaileshtripathi/goxplorer:0.99.0

USER root
ENV NB_USER=rstudio \
    VIRTUAL_ENV=/opt/venv
ENV PATH=${VIRTUAL_ENV}/bin:${PATH}
ENV RSERVER_TIMEOUT=120 JUPYTER_RSESSION_PROXY_USE_SOCKET=no

# Rocker's own script (present in the Bioconductor image) installs Jupyter,
# jupyter-rsession-proxy (serves RStudio through Jupyter) and IRkernel.
RUN /rocker_scripts/install_jupyter.sh

# Binder requires a non-root user with uid 1000 owning $HOME; in the
# Bioconductor/rocker image that is the existing `rstudio` user.
COPY --chown=rstudio:rstudio . /home/rstudio
USER rstudio
WORKDIR /home/rstudio
EXPOSE 8888
CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--no-browser"]
