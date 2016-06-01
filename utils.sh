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

	sep="&"
	if [[ ! "$endpoint" =~ "?" ]]; then
		sep="?"
	fi

	echo "${endpoint}${sep}apikey=${RESIN_SUPERVISOR_API_KEY}"
}

function __curl {
	case "$1" in
		status)
			extraCurlArgs="--write-out %{http_code} --output /dev/null"
			;;
		response)
			extraCurlArgs=""
			;;
		*)
			echo "Usage: __curl [status|response] [method] [endpoint] (data)"
			exit 1
	esac

	shift

	method=$1
	endpoint=$2

	data="{}"
	if [ $# -eq  3 ]; then
		data=$3
	fi

	endpoint=$(appendApiKey ${endpoint})

	curl \
		"$extraCurlArgs" \
		--silent \
		-X "$method" \
		-H "Content-Type: application/json" \
		--data "$data" \
		"${RESIN_SUPERVISOR_ADDRESS}/${endpoint}" 2>/dev/null
}

function curlGetStatus {
	__curl "status" "$@"
}

function curlGetResponse {
	__curl "response" "$@"
}

function listImages {
	curlGetResponse "GET" "v1/images"
}


function listContainers {
	curlGetResponse "GET" "v1/containers?all=1"
}

function createImage {
	status=$(curlGetStatus "POST" "v1/images/create?fromImage=${IMAGE}:${ARCH}")
	checkErr "$status" "200"
}

function deleteImage {
	imageId=$1
	status=$(curlGetStatus "DELETE" "v1/images/${IMAGE}:${ARCH}?force=1")
	checkErr "$status" "200"
}

function createContainer {
	curlGetResponse \
		"POST" \
		"v1/containers/create" \
		"{\"Image\":\"${IMAGE}:${ARCH}\",\"HostConfig\":{\"Binds\":[\"/var/run/docker.sock:/var/run/docker.sock\"]},\"Cmd\":[\"${LOGGING_SERVER}\"]}"
}

function startContainer {
	containerId=$1
	status=$(curlGetStatus "POST" "v1/containers/${containerId}/start")
	checkErr "$status" "204"
}

function stopContainer {
	containerId=$1
	status=$(curlGetStatus "POST" "v1/containers/${containerId}/stop")
	checkErr "$status" "204"
}

function deleteContainer {
	containerId=$1
	status=$(curlGetStatus "DELETE" "v1/containers/${containerId}?force=1")
	checkErr "$status" "204"
}
