# Installation

There are two ways to use CoCoSim on your computer. You can install it as a MATLAB toolbox, or you can get a local copy of the source code. CoCoSim requires MATLAB version **R2014b** or newer. CoCoSim works better with recent versions of MATLAB.

## Installation using MATLAB toolbox

The CoCoSim toolbox (CoCoSim.mltbx) contains Linux and macOS binaries for the backend solvers. You can download the latest release for CoCoSim toolbox from [here](https://github.com/coco-team/cocoSim2/releases). 

The following video explains how to install and start CoCoSim: 

[![Installation](https://github.com/coco-team/cocoSim2/blob/master/doc/videos/installation.png)](http://milner.cs.uiowa.edu/cocosim/installation.mp4)

The latest version of CoCoSim depends on the [Kind 2](https://github.com/kind2-mc/kind2) model checker. Kind 2 binaries for Linux and macOS are provided in the toolbox. Alternatively, CoCoSim can run Kind 2 remotely as a [web service](#kind2-web-service) or locally as a [Docker](#docker) image. Please note that Kind 2 binaries are not available for Windows. 

## Installation using source code

1. Clone the CoCoSim repository: ```git clone https://github.com/coco-team/cocoSim2```
2. For Linux and macOS users: download and extract the tools zip file ```https://github.com/coco-team/cocoSim2/releases/download/v.0.4/tools.zip``` into the ```cocoSim2``` folder. For Windows, configure CoCoSim to use the [Kind 2 web service](#kind2-web-service) or a [Docker](#docker) image of Kind 2.

### Kind2 web service

The following video explains how to configure CoCoSim to use the Kind 2 web service:

[![Kind2 web service](https://github.com/coco-team/cocoSim2/blob/master/doc/videos/kind2WebService.PNG)](http://milner.cs.uiowa.edu/cocosim/kind2WebService.mp4)

### Docker

The following video explains how to install and configure CoCoSim to use a Docker image of Kind 2:

[![Docker](https://github.com/coco-team/cocoSim2/blob/master/doc/videos/docker.PNG)](http://milner.cs.uiowa.edu/cocosim/docker.mp4)

## Launching

+ Launch MATLAB
+ Run the command ```start_cocosim```
+ You can now open and verify your Simulink model

