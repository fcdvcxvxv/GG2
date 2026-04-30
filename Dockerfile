FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    novnc \
    websockify \
    wget \
    curl \
    unzip \
    net-tools \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /proxmox8 /iso /novnc /logs

# Install latest noVNC
RUN wget https://github.com/novnc/noVNC/archive/refs/heads/master.zip -O /tmp/novnc.zip && \
    unzip /tmp/novnc.zip -d /tmp && \
    mv /tmp/noVNC-master/* /novnc && \
    rm -rf /tmp/*

# Default ENV values (can override in docker run)
ENV RAM=4096
ENV CPU=2
ENV DISK_SIZE=64G
ENV ISO_URL=https://enterprise.proxmox.com/iso/proxmox-ve_9.1-1.iso

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
RAM_MB=${RAM}\n\
CPU_CORES=${CPU}\n\
DISK_SIZE=${DISK_SIZE}\n\
ISO_URL=${ISO_URL}\n\
\n\
# Convert RAM\n\
RAM="${RAM_MB}M"\n\
\n\
# KVM check\n\
if [ -e /dev/kvm ]; then\n\
  echo "✅ KVM enabled"\n\
  KVM="-enable-kvm"\n\
  CPU_TYPE="host"\n\
else\n\
  echo "⚠️ No KVM (slow mode)"\n\
  KVM=""\n\
  CPU_TYPE="qemu64"\n\
fi\n\
\n\
mkdir -p /proxmox8 /iso\n\
\n\
# Download ISO if not exists\n\
if [ ! -f "/iso/proxmox.iso" ]; then\n\
  echo "📥 Downloading Proxmox ISO..."\n\
  wget -q --show-progress "$ISO_URL" -O /iso/proxmox.iso\n\
fi\n\
\n\
# Create disk if not exists\n\
if [ ! -f "/proxmox8/disk.qcow2" ]; then\n\
  echo "💽 Creating disk: $DISK_SIZE"\n\
  qemu-img create -f qcow2 /proxmox8/disk.qcow2 $DISK_SIZE\n\
fi\n\
\n\
echo "🚀 Starting Proxmox Installer"\n\
echo "RAM: ${RAM_MB}MB | CPU: ${CPU_CORES} | Disk: ${DISK_SIZE}"\n\
\n\
qemu-system-x86_64 \\\n\
  $KVM \\\n\
  -machine q35 \\\n\
  -cpu $CPU_TYPE \\\n\
  -m $RAM \\\n\
  -smp $CPU_CORES \\\n\
  -vga std \\\n\
  -boot d \\\n\
  -drive file=/proxmox8/disk.qcow2,format=qcow2 \\\n\
  -drive file=/iso/proxmox.iso,media=cdrom \\\n\
  -netdev user,id=net0,hostfwd=tcp::8006-:8006 \\\n\
  -device e1000,netdev=net0 \\\n\
  -display vnc=:0 \\\n\
  -name "Proxmox-Installer" &\n\
\n\
sleep 5\n\
websockify --web /novnc 6080 localhost:5900 &\n\
\n\
echo "===================================="\n\
echo "🌐 noVNC: http://localhost:6080"\n\
echo "🌐 After install: https://localhost:8006"\n\
echo "===================================="\n\
\n\
tail -f /dev/null\n' > /start.sh && chmod +x /start.sh

VOLUME ["/proxmox8", "/iso", "/logs"]

EXPOSE 6080 8006 5900

CMD ["/start.sh"]
