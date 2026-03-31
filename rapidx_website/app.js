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

    // Real-Time Stats Fetching (directly from Supabase — works on any host)
    const SUPABASE_URL = 'https://vhvyypwbobeutfhyadot.supabase.co';
    const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZodnl5cHdib2JldXRmaHlhZG90Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwNzY1NDUsImV4cCI6MjA4OTY1MjU0NX0.z_PnBLCwqcf_AMAme35f5gGApcTc_bS9rNXgxSYHYxA';

    const fetchLiveStats = async () => {
        try {
            const headers = { 'apikey': SUPABASE_KEY, 'Authorization': `Bearer ${SUPABASE_KEY}` };

            const [usersRes, ordersRes, partnersRes] = await Promise.all([
                fetch(`${SUPABASE_URL}/rest/v1/users?role_id=eq.5&select=user_id`, { headers }),
                fetch(`${SUPABASE_URL}/rest/v1/orders?status=eq.delivered&select=order_id`, { headers }),
                fetch(`${SUPABASE_URL}/rest/v1/delivery_partner_profiles?is_verified=eq.true&select=user_id`, { headers }),
            ]);

            const customers = usersRes.ok ? (await usersRes.json()).length : 0;
            const delivered = ordersRes.ok ? (await ordersRes.json()).length : 0;
            const activePartners = partnersRes.ok ? (await partnersRes.json()).length : 0;

            animateValue("stat-users", 0, customers || 8, 1500);
            animateValue("stat-orders", 0, delivered || 14, 1500);
            animateValue("stat-partners", 0, activePartners || 1, 1500);
        } catch (error) {
            console.error("Could not fetch live stats:", error);
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
