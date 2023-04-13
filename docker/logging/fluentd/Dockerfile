# FROM fluent/fluentd:v1.12
# RUN gem install faraday -v 1.10.2
# RUN gem install faraday-net_http -v 2.1.0
# RUN gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 5.2.0
# COPY fluent.conf /fluentd/etc

FROM fluent/fluentd:v1.16
RUN gem install elasticsearch -v 7.6
RUN gem install fluent-plugin-elasticsearch
RUN gem install fluent-plugin-rewrite-tag-filter
RUN gem install fluent-plugin-multi-format-parser
COPY fluent.conf /fluentd/etc
