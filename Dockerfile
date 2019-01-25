FROM jakubborys/ditc-base

ADD wheelhouse /var/nameko/wheelhouse

COPY config.yml /var/nameko/config.yml
COPY alembic.ini /var/nameko/alembic.ini
ADD alembic /var/nameko/alembic

WORKDIR /var/nameko/

RUN . /appenv/bin/activate; \
    pip install --no-index -f wheelhouse orders

RUN rm -rf /var/nameko/wheelhouse

EXPOSE 8000

CMD . /appenv/bin/activate; \
    alembic upgrade head \
    nameko run --config config.yml orders.service --backdoor 3000
