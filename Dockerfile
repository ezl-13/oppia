# Copyright 2014 The Oppia Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS-IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##########################################################################

# INSTRUCTIONS:
#
# This Dockerfile allows for an easy installation of Oppia for Windows
# users and a more reliable testing environment for running test scripts.
# 
# Current known limitations:
#   - no support for run_e2e_tests.sh
#   - run_frontend_tests.sh might not run correctly every time
#
##########################################################################
###################### TO SET UP THE OPPIA REPOSITORY ####################
##########################################################################
#
# STEP 1
# Download Docker Desktop for Windows here:
# https://hub.docker.com/editions/community/docker-ce-desktop-windows
#
# STEP 2
# Start Docker by clicking on the Docker application (a Docker icon should
# appear in your taskbar tray).
#
# STEP 3
# Build the Docker image from the Oppia root folder (note the "." at the
# end of the command):
#
#   docker build -t {some_name} .
#   ex: docker build -t oppia_image .
#
# Expect up to a 2 minute delay until the first line of output is printed.
# Runtime: 15-25 minutes
# If this is not your first time running this command, add --no-cache flag 
# to rebuild from the beginning:
#   docker build -t {some_name} . --no-cache
#   ex: docker build -t oppia_image . --no-cache
#
# STEP 4
# Follow the instructions on how to start the Oppia server.
#
##########################################################################
######################## TO START THE OPPIA SERVER #######################
##########################################################################
#
# STEP 1
# Start bash in the Docker image:
#
#   docker run -u 0 -it -p 8181:8181 {some_name}:latest /bin/bash
#   ex: docker run -u 0 -it -p 8181:8181 oppia_image:latest /bin/bash
#
# If Docker outputs an error, run:
#   docker ps
# This displays a repository name and tag name. Now run:
#   docker run -u 0 -it -p 8181:8181 {repository}:{tag} /bin/bash
#
# STEP 2
# Now you should have a new terminal prompt "root@...". Run the start.sh
# script:
#
#   bash scripts/start.sh
#
# Runtime: 10-20 minutes
# The script opens a server at localhost:8181. After the terminal prints
# "INFO ... http://0.0.0.0:8181" or "+ 27 hidden modules", open 
# localhost:8181 in your local computer browser. If the Oppia server does
# not load, restart this step.
#
##########################################################################
########################## TO RUN FRONTEND TESTS #########################
##########################################################################
#
# STEP 1
# Start bash in the Docker image (follow STEP 1 above)
#
# STEP 2
# Run the run_frontend_tests.sh script:
#
#   bash scripts/run_frontend_tests.sh
#
# Runtime: 3-7 minutes
# If this outputs an error ("failed before timeout of 2000ms"), continue
# to STEP 3.
# If this runs correctly (displays "SUCCESS"), do not go onto STEP 3.
#
# STEP 3
# Compile the frontend tests and then run the tests:
#
#   ./node_modules/typescript/bin/tsc --project .
#   ./node_modules/karma/bin/karma start ./core/tests/karma.conf.ts
#
# If this outputs an error, try STEP 2 again.
# If this runs correctly, you will see a SIGKILL at the end. That is okay.

##########################################################################

FROM ubuntu:latest

# Install packages needed in Dockerfile
RUN apt-get update && \
   apt-get install -y sudo && \
   apt-get install -y vim && \
   apt-get install -y wget && \
   apt-get install -y nodejs && \
   apt-get install -y npm && \
   apt-get install -y yes && \
   apt-get clean

# Create oppia directory in Docker container
RUN mkdir /home/oppia

# Install prerequisites. The yes package responds "yes" to all prompts.
COPY ./scripts/install_prerequisites.sh /home/oppia/scripts/
RUN yes | bash /home/oppia/scripts/install_prerequisites.sh

# Fix certificate issues
RUN apt-get update && \
   apt-get install ca-certificates-java && \
   apt-get clean && \
   update-ca-certificates -f

# Setup JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV PATH $PATH:$JAVA_HOME/bin
RUN export JAVA_HOME

# Install dumb-init (Signal handling of SIGINT/SIGTERM/SIGKILL etc.)
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb
RUN dpkg -i dumb-init_*.deb
ENTRYPOINT ["dumb-init"]

# Install packages needed for Google Chrome
RUN apt-get update && \
   apt-get install -y fonts-liberation libappindicator3-1 libgtk-3-0 libxss1 lsb-release xdg-utils

# Install Google Chrome for frontend tests
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN sudo dpkg -i google-chrome-stable_current_amd64.deb

# Copy oppia files into container
COPY . /home/oppia/
RUN rm /home/oppia/Dockerfile

# Allow docker to have sudo privileges
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
USER docker

WORKDIR /home/oppia/
