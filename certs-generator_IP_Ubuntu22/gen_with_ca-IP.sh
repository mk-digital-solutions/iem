#!/bin/bash

# Copyright (c) 2018-2022, Siemens AG (http://www.siemens.com)
# All rights reserved.
# THIS IS PROPRIETARY SOFTWARE OWNED BY SIEMENS AG.
# USE ONLY PERMITTED ACCORDING TO LICENSE AGREEMENT.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL SIEMENS AG OR ITS CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


path=$(dirname "$0")

IEM_IP=$1

mkdir -p "${path}"/out

openssl genrsa -out "${path}"/out/myCA.key 4096

openssl req -x509 -new -nodes -key "${path}"/out/myCA.key -sha256 -days 825 -out "${path}"/out/myCA.crt -config "${path}"/ca.conf

openssl genrsa -out "${path}"/out/myCert.key 4096

openssl req -new -key "${path}"/out/myCert.key -out "${path}"/out/myCert.csr -subj "/C=DE/ST=Dummy/L=Dummy/O=Dummy/CN=$IEM_IP" -config <(cat "${path}"/cert.conf <(printf "\\n[alt_names]\\nIP.1=%s" "${IEM_IP}"))

openssl x509 -req -in "${path}"/out/myCert.csr -CA "${path}"/out/myCA.crt -CAkey "${path}"/out/myCA.key -CAcreateserial -out "${path}"/out/myCert.crt -days 825 -sha256 -extfile <(cat "${path}"/cert-ext.conf <(printf "\\n[alt_names]\\nIP.1=%s" "${IEM_IP}"))

cat "${path}"/out/myCert.crt "${path}"/out/myCA.crt > "${path}"/out/certChain.crt

rm "${path}"/out/myCert.csr
cp "${path}"/out/myCert.crt "${path}"/out/certChain.crt "$(pwd)"/
