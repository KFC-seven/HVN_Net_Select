# HVN Net Select
This project is an official implementation of the paper "An Adaptive Network Selection Method for Enhancing Physical Layer Security in Heterogeneous Vehicular Networks", which proposes a fuzzy logic and TOPSIS-based Adaptive Network Selection Method for Enhancing Physical Layer Security (PLS) in Heterogeneous Vehicular Networks (HVNs).

## Citation
If you use this code or dataset in your work, please cite the following paper:

Y. Zhong, F. Xiao and D. Li, "An Adaptive Network Selection Method for Enhancing Physical Layer Security in Heterogeneous Vehicular Networks," in IEEE Transactions on Vehicular Technology, vol. 74, no. 9, pp. 14675-14691, Sept. 2025, doi: 10.1109/TVT.2025.3564987.

# Core contributions
✅ Hybrid assessment framework: combining fuzzy logic pre-screening, AHP/EWM weighting analysis, and TOPSIS decision-making

✅ Novel security metrics: first introduction of Connection Outage Probability (COP) and Secrecy Outage Probability (SOP) to network selection

✅ Extensible model: stochastic geometry-based 2D network modelling supports multi-RAT scenario analysis

# Usage Instructions

## Step 1: Run `step1_move` - V2X Dynamic Simulation Data
This step generates simulation data for dynamic scenarios in Vehicle-to-Everything (V2X) networks. It supports random road network construction, vehicle node distribution simulation, and visualization.

### Environment Initialization and Parameter Settings

- ​**Communication Protocol Parameters**: Define attributes for DSRC, LTE, and NR communication protocols (e.g., latency, bandwidth, packet loss rate).

- ​**Channel Model Parameters**: Set path loss exponent (LOS/NLOS), shadow fading parameters, etc., to simulate wireless channel characteristics.

- ​**Node Density**: Configure road density, base station (BS) density, transmitter/receiver node density, and eavesdropper density.

- ​**Motion Parameters**: Vehicle speed follows a normal distribution. Set typical vehicle speed (60 km/h) and communication coverage range (big circle `bigr` and small circle `smallr`).

### Road and Node Generation

- ​**Road Generation**: Generate roads based on a Poisson process to ensure density matches the set value. Road directions are random, with the last road forced to pass through the origin (typical vehicle location).

- ​**Base Station (BS) Generation**: Randomly distribute BSs within the circle based on density, assign different communication protocols, and calculate distances and channel parameters relative to the typical vehicle.

- ​**V2X Node Generation**:
   - **Receiver** and **Transmitter**: Distributed on roads according to density. Attributes include protocol, speed, direction, and communication parameters (latency, bandwidth, etc.).
   - **Eavesdropper**: Randomly distributed on roads to simulate potential security threats.

### Dynamic Simulation and Updates

- ​**Vehicle Movement**: The typical vehicle and other nodes move according to speed and direction, with positions updated over time.

- ​**Communication Parameter Updates**: Node communication parameters (e.g., latency, bandwidth) are dynamically adjusted based on distance, using exponential functions and normal distributions to simulate real-world fluctuations.

- ​**Frame Processing**: Update node positions and parameters for each frame, saving images to generate a GIF animation.

### Visualization and Data Saving

- ​**Image Rendering**: Generate scene plots for the big circle (global view) and small circle (local view), using different colors/markers to distinguish node types (BS, receiver, transmitter, eavesdropper).

- ​**GIF Generation**: Combine multiple frames into a dynamic GIF to showcase the dynamic changes in vehicles and communication states.

- ​**Data Storage**: Save road, node positions, and communication parameters for each frame to `.mat` files for subsequent analysis.

## Step 2: Run `step2_test` - V2X COP/SOP Simulation Tool
This tool calculates the Connection Outage Probability (COP) and Secrecy Outage Probability (SOP) in V2X networks, supporting dynamic performance analysis for DSRC, LTE, and NR communication protocols.

### Features
- ​**Multi-Protocol Support**: Pre-configured parameters for DSRC, LTE, and NR protocols, with support for custom protocols.
- ​**Dynamic Parameter Adjustment**: Randomize communication parameters based on distance to simulate real-world channel fluctuations.
- ​**Parallel Computing**: Utilize MATLAB `parfor` to accelerate large-scale node processing.
- ​**Data Compatibility**: Seamless integration with road generation tools (e.g., `PLP-based V2X Road Generation`).

### Dependencies
- MATLAB R2018b or later
- Parallel Computing Toolbox (for parallel computing)
- Pre-generated road and node data (`.mat` files)

### Steps

1. **Data Preparation**  
   - Ensure the `./tmp/v60/{v2xRTDensity}/` path contains `small*.mat` files output by the road generation tool.
   - Example data format: Includes variables such as `smallv2xRs`, `smallv2xTs`, `smallBSs`, `Vehicle`.

2. **Parameter Configuration**  
   - Modify `v2xRTDensity` (vehicle density) and file paths:
     ```matlab
     v2xRTDensity = 5; % Vehicle density
     figFolder = './fig/v60/5/'; % Result image path
     tmpDataFolder = './tmp/v60/5/'; % Input data path
     dataFolder = './data1/v60/5/'; % Output data path
     ```
   - Adjust protocol parameters (e.g., `DSRC.delay`, `LTE.bandwidth`) in the code.

3. **Run Calculation**  
   - Execute the main script `step2_test.m`, which automatically processes input data and calculates COP/SOP.
   - Results are saved to `dataFolder`, including updated node parameters and COP/SOP values.

4. **Result Analysis**  
   - Load output files (e.g., `small_r_0.5_t_0_v_60.mat`) to access node data:
     ```matlab
     load('./data1/v60/5/small_r_0.5_t_0_v_60.mat');
     % Example: Access receiver COP/SOP
     receiver_cop = V2XReceivers(1).cop;
     receiver_sop = V2XReceivers(1).sop;
     ```

### Advanced Configuration

#### Custom Protocols
1. Modify `DSRC`, `LTE`, and `NR` structure parameters.
2. Extend protocols by updating the calculation logic in the `COPSOP_test` function.

#### Parallel Computing Optimization
- Adjust `parfor` loop granularity (e.g., node chunking) to match hardware resources.
- Replace `parfor` with `for` if parallel computing is not required.

## Step 3: Run `step3_select` - V2X Candidate Network Evaluation Tool
This tool evaluates the optimal communication network in V2X for multiple scenarios, supporting fuzzy logic and TOPSIS-based comprehensive evaluation.

### Features
- ​**Multi-Scenario Evaluation**: Supports safety, efficiency, and information service scenarios with customizable judgment matrices.
- ​**Fuzzy Logic Processing**: Fuzzify communication parameters to adapt to complex environments.
- ​**TOPSIS Algorithm**: Quantify network performance through the Technique for Order of Preference by Similarity to Ideal Solution.
- ​**Data Compatibility**: Seamless integration with road generation and COP/SOP calculation tools.

### Dependencies
- ​**MATLAB R2020a+** (required)
- ​**Custom Functions**: `fuzzy_logic` (fuzzy logic processing) and `TOPSIS` (scoring algorithm).
- ​**Input Data**: Ensure the `./data/v60/{v2xRTDensity}/` path contains `small*.mat` files (generated by the scenario generation tool).

### Execution Instructions
- Run the main script `step3_select.m`, which automatically processes input data and outputs results.
```
