# 🚀 Ultimate Local All-in-One AI Lab for Mac

Run this one command to turn your Mac into a private, high-powered research station:

```bash
git clone [https://github.com/mrlemongrass/local-aio-ai.git](https://github.com/yourusername/local-aio-ai.git) && cd ai-lab && chmod +x setup.sh && ./setup.sh


🛠 Troubleshooting Common Issues
When users run high-performance AI on external hardware, they usually hit one of these three walls. Adding this to your README will save you dozens of GitHub Issues later.

1. External Drive "Permission Denied"
macOS has strict security for external volumes. If the script can't write to the drive:

Go to System Settings > Privacy & Security > Full Disk Access.

Click the + and add Terminal (and Docker if using Docker Desktop).

Ensure your drive is formatted as APFS or ExFAT.

2. "Port 8080 is already in use"
If the user already has another service running (like a local web server or another AI tool):

The Fix: Change the port in the launch command: --port 8081.

Reminder: They must also update the OPENAI_API_BASE_URL in the docker-compose.yaml to match.

3. Model Loading "Out of Memory"
If a user tries to run the F16 model on a base Mac with 8GB or 16GB of RAM, it will crash.

The Fix: Use the setup.sh hardware detection to force a Q4_K_M or IQ4_XS quantization for lower-spec machines.

🌐 Remote Access Issues
Tailscale Not Connecting: Ensure "Allow Third-Party Apps" isn't blocked by your Mac's Firewall (System Settings > Network > Firewall).

WireGuard Handshake Failure: If using WireGuard, ensure you have forwarded UDP Port 51820 on your home router to your Mac's local IP.

WebUI Timeout: If accessing the UI via a VPN/Tailscale IP and it times out, ensure your docker-compose.yaml is listening on 0.0.0.0 (all interfaces) rather than just 127.0.0.1.

🧠 Pre-Configured System Prompt: "The Research Expert"
Gemma 4 is exceptionally good at reasoning, but it needs a "nudge" to handle 128k context without getting lost. Inside Open WebUI, go to Workspace > Models > Gemma 4 > Edit and paste this into the System Prompt:

Role: You are an elite Research Assistant specializing in technical analysis, military communications, and doctoral-level academic synthesis.

Operational Protocol:

Context Priority: Always prioritize information found in the attached documents (#) over your general training data.

Visual Data: If a document contains image descriptions or Docling-generated chart data, interpret them as if you are looking at the original figure.

Citations: Every claim MUST be followed by a citation in brackets, e.g., [Document Name, Page X].

Reasoning: Use your internal thought process to verify facts before responding. If you find conflicting data between two papers, highlight the discrepancy.

Formatting: Use structured Markdown with clear headings and bolded key terms for scannability.
