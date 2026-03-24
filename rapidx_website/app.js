// Simple Scroll Reveal Animation
document.addEventListener('DOMContentLoaded', () => {
    const reveals = document.querySelectorAll('.reveal');

    const revealOnScroll = () => {
        const windowHeight = window.innerHeight;
        const elementVisible = 150;

        reveals.forEach((reveal) => {
            const elementTop = reveal.getBoundingClientRect().top;
            if (elementTop < windowHeight - elementVisible) {
                reveal.classList.add('active');
            }
        });
    };

    window.addEventListener('scroll', revealOnScroll);
    
    // Trigger once on load
    revealOnScroll();
    
    // Also animate hero text directly
    document.querySelector('.hero-text').classList.add('active');

    // Handle Download Clicks
    const downloadBtns = document.querySelectorAll('.download-trigger');
    downloadBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            btn.innerHTML = '<i data-lucide="loader" class="spin"></i> Downloading...';
            lucide.createIcons();
            
            // Actually try to download the local apk file
            // Let's create an invisible link to trigger a real download if the file exists
            const link = document.createElement('a');
            link.href = 'rapidx-latest.apk'; 
            link.download = 'rapidx-latest.apk';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

            setTimeout(() => {
                btn.innerHTML = '<i data-lucide="check-circle"></i> Downloaded';
                btn.style.backgroundColor = '#2ea043'; // Github green success
                lucide.createIcons();
                
                // Reset after 5 seconds
                setTimeout(() => {
                    btn.innerHTML = '<i data-lucide="download-cloud"></i> Download Android APK';
                    btn.style.backgroundColor = 'var(--accent)';
                    lucide.createIcons();
                }, 5000);
            }, 1000); // reduced timeout since it's an actual file download trigger now
        });
    });

    // Real-Time Stats Fetching
    const fetchLiveStats = async () => {
        try {
            const response = await fetch('http://localhost:3000/api/users/dashboard-stats');
            if (response.ok) {
                const data = await response.json();
                
                // Animate Numbers
                animateValue("stat-users", 0, data.total_customers || 8, 1500);
                animateValue("stat-orders", 0, data.delivered_orders || 14, 1500);
                animateValue("stat-partners", 0, data.active_delivery_partners || 1, 1500);
            }
        } catch (error) {
            console.error("Could not fetch live stats:", error);
            // Fallbacks in case backend is offline
            document.getElementById('stat-users').innerText = '100+';
            document.getElementById('stat-orders').innerText = '1K+';
            document.getElementById('stat-partners').innerText = '50+';
        }
    };

    // Animated counter function
    const animateValue = (id, start, end, duration) => {
        const obj = document.getElementById(id);
        if (!obj) return;
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            obj.innerHTML = Math.floor(progress * (end - start) + start).toLocaleString() + "+";
            if (progress < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
    };

    // Call stats fetch immediately
    fetchLiveStats();
});
