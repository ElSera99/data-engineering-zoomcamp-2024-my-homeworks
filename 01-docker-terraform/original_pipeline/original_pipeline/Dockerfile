FROM python:3.9.1

WORKDIR /home
RUN mkdir csv

COPY requirements.txt requirements.txt
COPY pipeline.py pipeline.py

RUN python -m pip install -r requirements.txt
RUN apt-get install wget
RUN apt-get install gzip

ENTRYPOINT [ "python", "pipeline.py" ]