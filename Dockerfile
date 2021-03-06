FROM ubuntu:precise

MAINTAINER Nathanael Jones <nathanael.jones@gmail.com>

#Make a downloads directory
RUN mkdir -p /home/downloads
WORKDIR /home/downloads

#Install git, plus all download / compiler tools needed.
RUN apt-get update && apt-get -y install make gcc libreadline6 libreadline6-dev libtool wget curl unzip libncurses5-dev git build-essential && apt-get clean

#Download and unpack lua source
RUN cd /home/downloads && wget http://www.lua.org/ftp/lua-5.1.5.tar.gz && tar xzvf lua-5.1.5.tar.gz

#Build and install lua from source
RUN cd /home/downloads/lua-5.1.5 && make linux && make test && make install

# luarocks 2.1.1 was horrible, use 2.0.5
#Download an unpack luarocks source
RUN cd /home/downloads && wget http://luarocks.org/releases/luarocks-2.0.5.tar.gz && tar xzvf luarocks-2.0.5.tar.gz

#Build and install luarocks from source
RUN cd /home/downloads/luarocks-2.0.5 && ./configure && make install

#Install packages with luarocks. Update to include any dependencies not explictly listed.
#Lua rocks don't tend to have accurate depenency specifiers.
WORKDIR /home/downloads

#Install the packages with no dependencies first, so the wrong versions don't get installed
RUN luarocks install coxpcall 1.13.0-1 
RUN luarocks install luasocket 2.0.2-5
RUN luarocks install lpeg 0.12-1
RUN luarocks install luafilesystem 1.5.0-2
RUN luarocks install rings 1.2.3-2
RUN echo "y" | luarocks install sha2 0.2.0-1

#Install the 2nd level packages next
RUN luarocks install copas 1.1.6-1
RUN luarocks install cosmo 13.01.30-1
RUN luarocks install wsapi 1.5-1
RUN luarocks install markdown 0.32-2
RUN luarocks install penlight 1.3.1-1

#Install the 3rd, 4th, and 5th level packages next
RUN luarocks install xavante 2.2.1-1
RUN luarocks install wsapi-xavante 1.5-1
RUN luarocks install orbit 2.2.0-2


#Clone custom version of Pluto - Update if changed, tied to commit
RUN cd /home/downloads && git clone https://github.com/nathanaeljones/pluto.git pluto && cd pluto && git checkout 10bced6bdb5faba530efef71e2891446a7f9e2b4

#Build and install Pluto
RUN cd /home/downloads/pluto && make linux && cp pluto.so "/usr/local/lib/lua/5.1"

#Clone weaver-lua
RUN cd /home/downloads && git clone git://github.com/nathanaeljones/weaver-lua.git weaver
RUN chmod 777 /home/downloads/weaver/web/server.sh

EXPOSE 80
EXPOSE 8080

WORKDIR /home/downloads/weaver/web/


#Run weaver-lua

CMD  ["/bin/bash", "/home/downloads/weaver/web/server.sh"]



