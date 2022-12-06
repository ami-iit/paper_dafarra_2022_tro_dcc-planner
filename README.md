<h1 align="center">
 Dynamic Complementarity Conditions and Whole-Body Trajectory Optimization for Humanoid Robot Locomotion
</h1>

<div align="center">

S. Dafarra, G. Romualdi and D. Pucci "Dynamic Complementarity Conditions and Whole-Body Trajectory Optimization for Humanoid Robot Locomotion" in 2022 IEEE Transactions on Robotics (T-RO)

</div>

<p align="center">




https://user-images.githubusercontent.com/18591940/179483328-c17e007f-06e7-4ae1-acff-7df65bfbd708.mp4




<div align="center">
2022 IEEE Transactions on Robotics (T-RO)
</div>
 
<div align="center">
  <a href="#reproducing-the-experiments"><b>Installation</b></a> |
  <a href="https://ieeexplore.ieee.org/abstract/document/9847574"><b>IEEE</b></a> |
  <a href="https://arxiv.org/abs/2207.03198"><b>arXiv</b></a> |
  <a href="https://www.youtube.com/watch?v=Uc9o8TE32cw"><b>YouTube</b></a>
</div>

## Reproducing the experiments
We support running the experiments via the provided Docker image.

1. Pull the docker image:
    ```console
    docker pull ghcr.io/ami-iit/dcc-planner-docker:latest
    ```
2. Launch the container:
    ```console
    xhost +
    docker run -it --rm  \
               --device=/dev/dri:/dev/dri \
               --user user \
               --env="DISPLAY=$DISPLAY"  \
               --net=host \
               ghcr.io/ami-iit/dcc-planner-docker:latest
    ```
3. The application will start automatically

The videos and the data from the experiments will be saved in the folder ``../SavedVideos``.

It is possible to run tests with different parameters by running the following command
```console
OMP_NUM_THREADS=1 cpp_ws/build/dynamical-planner/bin/SolverForComparisonsUnitTest [options]
```
with ``[options]`` being:
```console
  -s, --solver                                Linear solver to use with ipopt (string [=mumps])
  -c, --complementarity                       Type of complementairity condition (string [=dynamical])
  -v, --velocity                              Linear walking velocity (d [=0.05])
      --normalForceDissipationRatio           Normal Force Dissipation Ratio (one of the two parameters of the hyperbolic complementarity method). (d [=250])
      --normalForceHyperbolicSecantScaling    Normal Force Hyperbolic Secant Scaling (one of the two parameters of the hyperbolic complementarity method). (d [=500])
      --complementarityDissipation            The rate of dissipation for the complementarity (one of the two parameters of the dynamical complementarity method). (d [=20])
      --dynamicComplementarityUpperBound      The upper-bound for the dynamic complementairty (one of the two parameters of the dynamical complementarity method). (d [=0.05])
      --classicalComplementarityTolerance     The upper bound for the classical complementarity. (d [=0.004])
  -?, --help                                  print this message
```

⚠️  In the docker image provided, only the linear solver ``mumps`` is supported.

⚠️  If you want to replicate the installation on your PC please follow the [Docker recipe](./dockerfiles/Dockerfile).


## Citing this work

If you find the work useful, please consider citing:

```bib
@ARTICLE{dafarra2022dcc,
  author={Dafarra, Stefano and Romualdi, Giulio and Pucci, Daniele},
  journal={IEEE Transactions on Robotics}, 
  title={Dynamic Complementarity Conditions and Whole-Body Trajectory Optimization for Humanoid Robot Locomotion}, 
  year={2022},
  volume={38},
  number={6},
  pages={3414-3433},
  doi={10.1109/TRO.2022.3183785}}
```



## Maintainer

This repository is maintained by:

|                                                              |                                                      |
| :----------------------------------------------------------: | :--------------------------------------------------: |
| [<img src="https://github.com/S-Dafarra.png" width="40">](https://github.com/S-Dafarra) | [@S-Dafarra](https://github.com/S-Dafarra) |
