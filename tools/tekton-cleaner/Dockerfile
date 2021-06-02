FROM ubuntu:18.04 as posrednik
RUN apt-get update && apt-get install curl sudo tar -y
RUN curl -LO https://github.com/tektoncd/cli/releases/download/v0.18.0/tkn_0.18.0_Linux_x86_64.tar.gz && sudo tar xvzf tkn_0.18.0_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn

FROM ubuntu:18.04
COPY --from=posrednik /usr/local/bin/tkn /usr/local/bin/
COPY tkn_cleanup.sh /tkn_cleanup.sh
USER 1000
ENTRYPOINT ["/tkn_cleanup.sh"]
CMD ["-c"]
