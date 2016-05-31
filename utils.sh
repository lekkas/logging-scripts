#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

function checkErr {
	status=$1
	expectedStatus=$1

	if [ "$status" -ne "$expectedStatus" ]; then
		echo "Error. Expected status $expectedStatus but got $status"
		exit 1
	fi
}

function appendApiKey {
	endpoint=$1
	if [[ ! "$endpoint" =~ "?" ]]; then
		sep="?"
	else
		sep="&"
	fi
	echo "${endpoint}${sep}apikey=${RESIN_SUPERVISOR_API_KEY}"
}

function curlGetStatus {
	method=$1
	endpoint=$2

	if [ $# -eq  3 ]; then
		data=$3
	else
		data="{}"
	fi

	endpoint=$(appendApiKey ${endpoint})
	curl \
		--silent \
		-X ${method} \
		-H "Content-Type: application/json" \
		--data "${data}" \
		--write-out %{http_code} --output /dev/null \
		"${RESIN_SUPERVISOR_ADDRESS}/${endpoint}" 2>/dev/null
}

function curlGetResponse {
	method=$1
	endpoint=$2

	if [ $# -eq  3 ]; then
		data=$3
	else
		data="{}"
	fi

	endpoint=$(appendApiKey ${endpoint})
	curl \
		--silent \
		-X ${method} \
		-H "Content-Type: application/json" \
		--data "${data}" \
		"${RESIN_SUPERVISOR_ADDRESS}/${endpoint}" 2>/dev/null
}

function listImages {
	curlGetResponse "GET" "v1/images"
}


function listContainers {
	curlGetResponse "GET" "v1/containers?all=1"
}

function createImage {
	status=$(curlGetStatus "POST" "v1/images/create?fromImage=${IMAGE}:${ARCH}")
	checkErr ${status} "200"
}

function deleteImage {
	imageId=$1
	status=$(curlGetStatus "DELETE" "v1/images/${IMAGE}:${ARCH}?force=1")
	checkErr ${status} "200"
}

function createContainer {
	curlGetResponse "POST" \
		"v1/containers/create" \
		"{\"Image\":\"${IMAGE}:${ARCH}\",\"HostConfig\":{\"Binds\":[\"/var/run/docker.sock:/var/run/docker.sock\"]},\"Cmd\":[\"${LOGGING_SERVER}\"]}"
}

function startContainer {
	containerId=$1
	status=$(curlGetStatus "POST" "v1/containers/${containerId}/start")
	checkErr ${status} "204"
}

function stopContainer {
	containerId=$1
	status=$(curlGetStatus "POST" "v1/containers/${containerId}/stop")
	checkErr ${status} "204"
}

function deleteContainer {
	containerId=$1
	status=$(curlGetStatus "DELETE" "v1/containers/${containerId}?force=1")
	checkErr ${status} "204"
}
