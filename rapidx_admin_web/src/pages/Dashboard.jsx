import React, { useState, useEffect } from 'react';
import {
    Users, Briefcase, Truck, Package, CheckCircle, Clock,
    XOctagon, DollarSign, TrendingUp, AlertTriangle, ShieldAlert, RefreshCw
} from 'lucide-react';
import {
    AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell,
    XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend
} from 'recharts';

const COLORS = ['#3b82f6', '#8b5cf6', '#10b981'];

const StatCard = ({ title, value, icon, color, trend, trendDown = false }) => (
    <div className={`stat-card ${color}`}>
        <div className="stat-info">
            <span className="stat-title">{title}</span>
            <span className="stat-value">{value}</span>
            {trend && (
                <span className={`stat-trend ${trendDown ? 'down' : 'up'}`}>
                    {trendDown ? '↓' : '↑'} {trend}
                </span>
            )}
        </div>
        <div className={`stat-icon ${color}`}>
            {icon}
        </div>
    </div>
);

const Dashboard = () => {
    const [stats, setStats] = useState(null);
    const [loading, setLoading] = useState(true);

    const fetchStats = async () => {
        try {
            const response = await fetch('http://localhost:3000/api/users/dashboard-stats');
            if (response.ok) {
                const data = await response.json();
                setStats(data);
            }
        } catch (error) {
            console.error("Error fetching dashboard stats:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchStats();
        // Refresh stats every minute
        const interval = setInterval(fetchStats, 60000);
        return () => clearInterval(interval);
    }, []);

    if (loading || !stats) {
        return <div style={{ padding: '2rem', textAlign: 'center' }}>Loading dashboard metrics...</div>;
    }

    const userDistribution = [
        { name: 'Customers', value: parseInt(stats.total_customers) || 0 },
        { name: 'Businesses', value: parseInt(stats.total_businesses) || 0 },
        { name: 'Delivery Partners', value: parseInt(stats.total_delivery_partners) || 0 },
    ];

    return (
        <div>
            <div className="page-header">
                <div>
                    <h1 className="page-title">Dashboard Overview</h1>
                    <p className="page-subtitle">Welcome back, here's what's happening today.</p>
                </div>
                <button className="primary-btn" onClick={fetchStats} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <RefreshCw size={16} /> Refresh
                </button>
            </div>

            <h3 className="panel-title" style={{ marginTop: '2rem' }}>Overview Metrics</h3>
            <div className="grid-cards">
                <StatCard title="Total Users" value={stats.total_users} icon={<Users />} color="blue" />
                <StatCard title="Total Customers" value={stats.total_customers} icon={<Users />} color="blue" />
                <StatCard title="Total Businesses" value={stats.total_businesses} icon={<Briefcase />} color="purple" />
                <StatCard title="Total Delivery Partners" value={stats.total_delivery_partners} icon={<Truck />} color="green" />
                <StatCard title="Active Delivery Partners" value={stats.active_delivery_partners} icon={<Truck />} color="green" />
                <StatCard title="Pending Partner Verifications" value={stats.pending_verifications} icon={<AlertTriangle />} color="warning" />
                <StatCard title="Blocked Accounts" value={stats.blocked_accounts} icon={<ShieldAlert />} color="danger" />
            </div>

            <div className="grid-2-cols" style={{ marginTop: '2rem' }}>
                <div className="panel" style={{ height: '350px' }}>
                    <h3 className="panel-title">Orders Overview (Weekly)</h3>
                    <ResponsiveContainer width="100%" height="90%">
                        <BarChart data={stats.orderTrend} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--border-light)" />
                            <XAxis dataKey="name" stroke="var(--text-secondary)" fontSize={12} tickLine={false} axisLine={false} />
                            <YAxis stroke="var(--text-secondary)" fontSize={12} tickLine={false} axisLine={false} />
                            <Tooltip
                                contentStyle={{ backgroundColor: 'var(--bg-secondary)', borderColor: 'var(--border-light)', borderRadius: 'var(--radius-md)' }}
                                cursor={{ fill: 'rgba(255,255,255,0.05)' }}
                            />
                            <Legend iconType="circle" wrapperStyle={{ fontSize: '12px', paddingTop: '10px' }} />
                            <Bar dataKey="total" fill="#3b82f6" radius={[4, 4, 0, 0]} name="Total Placed" />
                            <Bar dataKey="delivered" fill="#8b5cf6" radius={[4, 4, 0, 0]} name="Delivered" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>

                <div className="panel" style={{ height: '350px' }}>
                    <h3 className="panel-title">User Demographics</h3>
                    <ResponsiveContainer width="100%" height="90%">
                        <PieChart>
                            <Pie
                                data={userDistribution}
                                cx="50%"
                                cy="45%"
                                innerRadius={70}
                                outerRadius={100}
                                paddingAngle={5}
                                dataKey="value"
                                stroke="none"
                            >
                                {userDistribution.map((entry, index) => (
                                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                ))}
                            </Pie>
                            <Tooltip
                                contentStyle={{ backgroundColor: 'var(--bg-secondary)', borderColor: 'var(--border-light)', borderRadius: 'var(--radius-md)', color: 'var(--text-primary)' }}
                                itemStyle={{ color: 'var(--text-primary)' }}
                            />
                            <Legend iconType="circle" wrapperStyle={{ fontSize: '12px' }} />
                        </PieChart>
                    </ResponsiveContainer>
                </div>
            </div>

            <h3 className="panel-title" style={{ marginTop: '2rem' }}>Orders Summary</h3>
            <div className="grid-cards">
                <StatCard title="Total Orders" value={stats.total_orders} icon={<Package />} color="blue" />
                <StatCard title="Orders Placed Today" value={stats.orders_today} icon={<Package />} color="blue" />
                <StatCard title="Orders In Transit" value={stats.orders_in_transit} icon={<Truck />} color="warning" />
                <StatCard title="Delivered Orders" value={stats.delivered_orders} icon={<CheckCircle />} color="success" />
            </div>

            <h3 className="panel-title" style={{ marginTop: '2rem' }}>Revenue Overview</h3>
            <div className="grid-cards">
                <StatCard title="Total Platform Revenue" value={`₹${stats.total_revenue || 0}`} icon={<DollarSign />} color="success" />
            </div>

            <h3 className="panel-title" style={{ marginTop: '2rem' }}>Revenue Trends (Last 7 Days)</h3>
            <div className="panel" style={{ height: '300px', marginBottom: '2rem' }}>
                <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={stats.revenueTrend} margin={{ top: 10, right: 30, left: -20, bottom: 0 }}>
                        <defs>
                            <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor="#10b981" stopOpacity={0.8} />
                                <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
                            </linearGradient>
                        </defs>
                        <XAxis dataKey="name" stroke="var(--text-secondary)" fontSize={12} tickLine={false} axisLine={false} />
                        <YAxis stroke="var(--text-secondary)" fontSize={12} tickLine={false} axisLine={false} tickFormatter={(value) => `₹${value >= 1000 ? (value / 1000).toFixed(1) + 'k' : value}`} />
                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--border-light)" />
                        <Tooltip
                            contentStyle={{ backgroundColor: 'var(--bg-secondary)', borderColor: 'var(--border-light)', borderRadius: 'var(--radius-md)' }}
                            itemStyle={{ color: 'var(--text-primary)' }}
                        />
                        <Area type="monotone" dataKey="revenue" stroke="#10b981" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
                    </AreaChart>
                </ResponsiveContainer>
            </div>
        </div>
    );
};

export default Dashboard;
