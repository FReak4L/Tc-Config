<img src="https://socialify.git.ci/FReak4L/Tc-Config/image?description=1&font=Source%20Code%20Pro&language=1&logo=https%3A%2F%2Fraw.githubusercontent.com%2FFReak4L%2Fwarp-plus%2Fmain%2Fimg%2F%2540FReakXray.png&name=1&pattern=Brick%20Wall&theme=Dark" alt="repo image" />

<H2><p align="center"><strong>TC-Config</strong></p></H2>


<p align="center">
  <strong>Advanced Traffic Control Configuration for Xanmod Kernel</strong><br />
  This script optimizes your network traffic using sophisticated techniques to enhance performance and control.
</p>

## Features

<ul>
  <li><strong>Xanmod Kernel Detection:</strong> The script automatically verifies the presence of the Xanmod kernel, a performance-oriented kernel optimized for high-throughput and low-latency operations. This ensures that your system is primed for the advanced features the script is designed to implement.</li>
  <li><strong>System Update & Package Installation:</strong> Ensures that your system is up-to-date by performing a comprehensive update and installing critical networking tools. These components form the backbone of the script’s traffic control and QoS management capabilities.</li>
  <li><strong>Advanced QoS Configuration:</strong> Leverages <code>tc</code> (traffic control) with <code>HTB</code> (Hierarchical Token Bucket) to establish a sophisticated QoS system. This configuration enables precise control over traffic flow, ensuring efficient bandwidth distribution and prioritization of critical network traffic.</li>
  <li><strong>Multi-layer Traffic Shaping:</strong> Implements state-of-the-art traffic shaping techniques, incorporating cutting-edge algorithms such as <code>CAKE</code>, <code>FQ_Codel</code>, and <code>FQ_PIE</code>. These algorithms dynamically manage traffic queues to minimize latency and bufferbloat, delivering an optimized network experience.</li>
  <li><strong>Adaptive Queue Management:</strong> Utilizes adaptive queue management strategies that respond in real-time to network conditions, adjusting traffic flow to maintain optimal performance. This includes fine-tuning of queue disciplines to balance fairness and efficiency.</li>
  <li><strong>Intelligent Packet Manipulation:</strong> Applies advanced <code>iptables</code> rules for sophisticated packet filtering, redirection, and modification, enhancing both security and performance. The script intelligently adjusts TCP MSS values and applies custom ToS flags to optimize data flow.</li>
  <li><strong>Detailed Logging:</strong> Captures detailed logs of all operations for thorough auditing and troubleshooting, ensuring transparency and traceability in the script’s execution.</li>
</ul>


## Prerequisites

<ul>
  <li><strong>Xanmod Kernel:</strong> This script is designed to work with the Xanmod kernel. Make sure it's installed and running.</li>
  <li><strong>Required Packages:</strong> <code>iproute2</code>, <code>iptable</code></li>
</ul>

## Menu 
<img src="https://raw.githubusercontent.com/FReak4L/Tc-Config/main/img/menu.jpg" alt="Menu Script" />

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
<img src="https://raw.githubusercontent.com/FReak4L/Tc-Config/main/img/help.jpg" alt="Help Menu" />

## Steps and Configuration

Here's what the script does, step-by-step:

<ol>
  <li>
    <strong>Kernel Check:</strong> 
    <p>The script begins by ensuring the Xanmod kernel is active. This kernel is tailored for high-performance networking and system responsiveness, making it a critical component for the script's advanced traffic management features. If the correct kernel is not detected, the script provides immediate feedback, allowing you to take corrective action.</p>
    <img src="https://raw.githubusercontent.com/FReak4L/Tc-Config/main/img/chk-kernel.jpg" alt="Kernel Check" />
  </li>
  
  <li>
    <strong>System Update & Package Installation:</strong> 
    <p>Next, the script performs a comprehensive system update, ensuring all software is current. It then installs essential networking packages such as <code>iproute2</code> and <code>iptables</code>. These tools are fundamental for the script's operation, providing the necessary functionality for traffic control and quality of service management.</p>
  </li>
  
  <li>
    <strong>QoS Setup:</strong> 
    <p>The script then sets up <code>tc</code> with <code>HTB</code>, creating a multi-tiered traffic control structure. This setup allows for hierarchical bandwidth allocation, ensuring that critical traffic is prioritized while maintaining overall network efficiency. The use of HTB ensures that bandwidth is distributed according to predefined rules, optimizing network performance under varying loads.</p>
  </li>
  
  <li>
    <strong>Traffic Shaping:</strong> 
    <p>To further enhance network performance, the script implements advanced traffic shaping techniques using algorithms like <code>FQ_Codel</code>, <code>FQ_PIE</code>, and <code>CAKE</code>. These algorithms are designed to intelligently manage queue lengths and reduce network latency. By minimizing bufferbloat, they ensure a more responsive internet experience, particularly under conditions of heavy network usage.</p>
  </li>
  
  <li>
    <strong>Advanced Traffic Optimization:</strong>
    <p>The script then configures a complex queue discipline structure, tailoring it to various types of traffic such as video streaming, gaming, or bulk downloads. This customization allows each type of traffic to be handled according to its specific needs, optimizing both performance and user experience. The script's use of advanced algorithms like <code>CAKE</code> and <code>FQ_PIE</code> enables it to adapt dynamically to changing network conditions, ensuring consistent performance.</p>
  </li>


## Script Menu

<p>The script provides a user-friendly menu where you can select your network interface and set your desired uplink and downlink speeds:</p>

<ul>
  <li>Interface: <code>eth0</code> (default), <code>ens3</code>, or custom.</li>
  <li>Uplink: <code>5gbit</code> (default), <code>1gbit</code>, or custom.</li>
  <li>Downlink: <code>5gbit</code> (default), <code>1gbit</code>, or custom.</li>
</ul>

<p align="center">
  <img src="https://raw.githubusercontent.com/FReak4L/Tc-Config/main/img/step.jpg" alt="Script Steps" />
</p>

## Logging

<p>All actions performed by the script are logged to <code>/var/log/tc-freak.log</code>. This log can be very useful for troubleshooting or simply reviewing the changes made by the script.</p>

<p align="center">
  <a href="https://t.me/FReak_4L">
    <img src="https://img.icons8.com/?size=100&id=k4jADXhS5U1t&format=png&color=000000" alt="Telegram" />
  </a>
  <br />
  <a href="https://t.me/FReak_4L">DM</a>
</p>

## License

<p>This project is licensed under the GNU General Public License v3.0.</p>

<p align="center"><strong>Note:</strong> Use this script at your own risk. It is provided "as is" without any warranty.</p>
