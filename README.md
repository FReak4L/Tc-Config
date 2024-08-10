
# Tc-Config


<p align="center">
  <strong>Advanced Traffic Control Configuration for Xanmod Kernel</strong><br />
  This script optimizes your network traffic using sophisticated techniques to enhance performance and control.
</p>

## Features

<ul>
  <li><strong>Kernel Detection:</strong> Automatically checks if the Xanmod kernel is active.</li>
  <li><strong>System Update:</strong> Updates and upgrades your system, then installs the required packages.</li>
  <li><strong>QoS Configuration:</strong> Sets up `tc` for efficient traffic management using Hierarchical Token Bucket (HTB) and other queue disciplines (qdisc).</li>
  <li><strong>Traffic Shaping:</strong> Implements advanced traffic shaping, prioritization, and obfuscation techniques.</li>
  <li><strong>Logging:</strong> All actions are logged for easy troubleshooting and auditing.</li>
</ul>

## Prerequisites

<ul>
  <li><strong>Xanmod Kernel:</strong> This script is designed to work with the Xanmod kernel. Make sure it's installed and running.</li>
  <li><strong>Required Packages:</strong> `iproute2`, `iptables`</li>
</ul>

## Installation

<p>To run this script directly using <strong>wget</strong> or <strong>curl</strong>, follow the instructions below:</p>

<h3>Using curl:</h3>

```bash
bash <(curl -s https://raw.githubusercontent.com/FReak4L/Tc-Config/main/tc.sh) -s
```

<h3>Using wget:</h3>

```bash
bash <(wget -qO- https://raw.githubusercontent.com/FReak4L/Tc-Config/main/tc.sh) -s
```

## Usage

<p>To execute the script, simply run:</p>

```bash
bash tc.sh -s
```

<p>This will start the script and you'll be prompted to select your network interface and specify your uplink and downlink bandwidth. You can use the defaults or input your own values.</p>

<h3>Example</h3>

```bash
bash tc.sh -h
```

## Steps and Configuration

Here's what the script does, step-by-step:

<ol>
  <li>
    <strong>Kernel Check:</strong> 
    <p>The script starts by checking if you're using the Xanmod kernel. This is crucial because the script is optimized for the advanced features provided by Xanmod.</p>
    <img src="[https://github.com/FReak4L/Tc-Config/raw/main/img/check_kernel.jpg](https://raw.githubusercontent.com/FReak4L/Tc-Config/main/img/chk-kernel.jpg)" alt="Kernel Check" />
  </li>
  
  <li>
    <strong>System Update & Package Installation:</strong> 
    <p>Next, it updates your system and installs necessary packages like `iproute2` and `iptables`. These tools are essential for managing network traffic and applying the QoS rules.</p>
    <img src="https://github.com/FReak4L/Tc-Config/raw/main/img/installing_required.jpg" alt="System Update & Package Installation" />
  </li>
  
  <li>
    <strong>QoS Setup:</strong> 
    <p>Here, `tc` (traffic control) is configured with HTB (Hierarchical Token Bucket) to manage your network traffic. This setup ensures that traffic is allocated fairly among different types of network usage, prioritizing important traffic when necessary.</p>
  </li>
  
  <li>
    <strong>Traffic Shaping:</strong> 
    <p>The script then implements traffic shaping techniques using advanced queue disciplines like `fq_codel`, `fq_pie`, and `cake`. These help reduce latency and bufferbloat, leading to a smoother internet experience.</p>
  </li>
  
  <li>
    <strong>Traffic Management & Obfuscation:</strong> 
    <p>Finally, `iptables` rules are added to manage and obfuscate traffic. This step is important for ensuring that your network remains efficient and secure, by controlling the flow of packets and preventing congestion.</p>
  </li>
</ol>

## Script Menu

<p>The script provides a user-friendly menu where you can select your network interface and set your desired uplink and downlink speeds:</p>

<ul>
  <li>Interface: `eth0` (default), `ens3`, or custom.</li>
  <li>Uplink: `5gbit` (default), `1gbit`, or custom.</li>
  <li>Downlink: `5gbit` (default), `1gbit`, or custom.</li>
</ul>

<p align="center">
  <img src="https://github.com/FReak4L/Tc-Config/raw/main/img/steps.jpg" alt="Script Steps" />
</p>

## Logging

<p>All actions performed by the script are logged to <code>/var/log/tc-freak.log</code>. This log can be very useful for troubleshooting or simply reviewing the changes made by the script.</p>

## Contribution

<p>If you have suggestions or want to contribute, feel free to open an issue or submit a pull request.</p>

## License

<p>This project is licensed under the MIT License.</p>

<p align="center"><strong>Note:</strong> Use this script at your own risk. It is provided "as is" without any warranty.</p>
