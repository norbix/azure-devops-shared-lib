# Introduction 

These templates can be shared between pipelines. 

# Getting Started

```shell 
parameters:
  command: |
    echo in-agent-with-aws-creds default command
  env: {}
  displayName: Run in agent with aws creds
  always: false
  condition: true
  name: ''

steps:
  - script: |
      rm -f .custom-env
      for var in $(compgen -v | grep -Ev '^(BASH)|(^PATH)|(XDG)|(GNOME)|(^HIST)|(^HOST)|(^LC)|(^_)|(^AGENT)|(^SYSTEM)|(^JAVA)|(^HOME)|(^BUILD)'); do
          var_fixed=$(printf "%s" "${!var}" | tr -d '\n' )
          echo "$var=${var_fixed}" >>.custom-env
      done
      WORKDIR=$(pwd)
      docker run \
        --env-file .custom-env \
        --rm \
        -v "${WORKDIR}:${WORKDIR}" \
        -w "${WORKDIR}" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        ubuntu:20.04 \        
        /bin/bash -c \
        "
        rm -f .custom-env
        export AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)
        export AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
        export AWS_DEFAULT_REGION=$(AWS_DEFAULT_REGION)
        export AWS_REGION=$(AWS_REGION)
        echo Running with access key [$AWS_ACCESS_KEY_ID] on [$AWS_REGION]
        ${{ parameters.command }}
        "
    env:
      AWS_SECRET_ACCESS_KEY: $(AWS_SECRET_ACCESS_KEY)
      ${{ insert }}: ${{ parameters.env }}
    displayName: ${{ parameters.displayName }}
    condition: or(${{ parameters.always }}, and(succeeded(), ${{ parameters.condition }}))
    ${{ if not(eq( parameters.name, '')) }}:
      name: ${{ parameters.name }}

  - template: set-pwd-ownership.yaml
```