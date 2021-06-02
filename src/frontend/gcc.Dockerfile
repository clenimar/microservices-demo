# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM golang:1.15-alpine as builder
RUN apk add --no-cache ca-certificates git gcc gcc-go musl-dev busybox-extras net-tools bind-tools
WORKDIR /src

# restore dependencies
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -compiler gccgo -buildmode=exe -gccgoflags -g -o /go/bin/frontend .

FROM alpine:3.14 as release
RUN apk add --no-cache libgo ca-certificates busybox-extras net-tools bind-tools
WORKDIR /frontend
COPY --from=builder /go/bin/frontend /frontend/server
COPY ./templates ./templates
COPY ./static ./static
EXPOSE 8080
ENTRYPOINT ["/frontend/server"]
