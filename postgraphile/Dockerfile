FROM graphile/postgraphile

WORKDIR /postgraphile/

RUN yarn add postgraphile
RUN yarn add graphile-build
RUN yarn add graphile-build-pg
RUN yarn add @graphile/pg-pubsub

EXPOSE 5000

ENTRYPOINT ["./cli.js", "--plugins", "@graphile/pg-pubsub", "--port", "5000"]
