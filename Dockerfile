FROM ubuntu:22.04 as base

WORKDIR /opt/openharmony

SHELL [ "/bin/bash", "-c" ]

#copy your own toolchain into /opt/openharmony/ and the entrypoint.sh contains "source env.sh", remember to modify your own env.sh as well
COPY gcc_riscv32 /opt/openharmony/
COPY gn /opt/openharmony/
COPY llvm /opt/openharmony/
COPY env.sh /opt/openharmony/

COPY entrypoint.sh /opt


RUN apt-get -y update \
    && apt-get -y install python3 python3-venv python3-pip bison ccache default-jdk libffi-dev dumb-init \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*


RUN python3 -m venv /opt/openharmony/.venv

#if you'd like to change venv pip source, uncomment this line
#COPY pip.conf /opt/openharmony/.venv/

#if there throws a Crypto error, try "pip uninstall pycryptodome && pip install pycrypto"
RUN source /opt/openharmony/.venv/bin/activate \
    && pip install setuptools pycryptodome ecdsa scons ninja

RUN sed -i '9s/.*/from collections.abc import Mapping/' /opt/openharmony/.venv/lib/python3.10/site-packages/prompt_toolkit/styles/from_dict.py

RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/opt/entrypoint.sh"]

