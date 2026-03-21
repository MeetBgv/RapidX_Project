import React from 'react';
import {
    Users, Briefcase, Truck, Package, CheckCircle, Clock,
    XOctagon, DollarSign, TrendingUp, AlertTriangle, ShieldAlert
} from 'lucide-react';
import {
    AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell,
    XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend
} from 'recharts';

// Dummy data for charts
const revenueData = [
    { name: 'Mon', revenue: 24000 },
    { name: 'Tue', revenue: 13980 },
    { name: 'Wed', revenue: 98000 },
    { name: 'Thu', revenue: 39080 },
    { name: 'Fri', revenue: 48000 },
    { name: 'Sat', revenue: 38000 },
    { name: 'Sun', revenue: 43000 },
];

const orderData = [
    { name: 'Mon', total: 4000, delivered: 2400 },
    { name: 'Tue', total: 3000, delivered: 1398 },
    { name: 'Wed', total: 2000, delivered: 9800 },
    { name: 'Thu', total: 2780, delivered: 3908 },
    { name: 'Fri', total: 1890, delivered: 4800 },
    { name: 'Sat', total: 2390, delivered: 3800 },
    { name: 'Sun', total: 3490, delivered: 4300 },
];

const userDistribution = [
    { name: 'Customers', value: 12456 },
    { name: 'Businesses', value: 1102 },
    { name: 'Delivery Partners', value: 3120 },
];

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
    return (
        <div>
            <div className="page-header">
                <div>
                    <h1 className="page-title">Dashboard Overview</h1>
                    <p className="page-subtitle">Welcome back, here's what's happening today.</p>
                </div>
                <button className="primary-btn">Download Report</button>
            </div>

            <h3 className="panel-title" style={{ marginTop: '2rem' }}>Overview Metrics</h3>
            <div className="grid-cards">
                <StatCard title="Total Users" value="12,456" icon={<Users />} color="blue" trend="12% from last month" />
                <StatCard title="Total Customers" value="8,234" icon={<Users />} color="blue" />
                <StatCard title="Total Businesses" value="1,102" icon={<Briefcase />} color="purple" />
                <StatCard title="Total Delivery Partners" value="3,120" icon={<Truck />} color="green" />
                <StatCard title="Active Delivery Partners" value="2,845" icon={<Truck />} color="green" />
                <StatCard title="Pending Partner Verifications" value="134" icon={<AlertTriangle />} color="warning" />
                <StatCard title="Blocked Accounts" value="45" icon={<ShieldAlert />} color="danger" />
            </div>

            <div className="grid-2-cols" style={{ marginTop: '2rem' }}>
                <div className="panel" style={{ height: '350px' }}>
                    <h3 className="panel-title">Orders Overview (Weekly)</h3>
                    <ResponsiveContainer width="100%" height="90%">
                        <BarChart data={orderData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
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
                <StatCard title="Total Orders" value="452,890" icon={<Package />} color="blue" />
                <StatCard title="Orders Placed Today" value="1,432" icon={<Package />} color="blue" trend="5% from yesterday" />
                <StatCard title="Orders In Transit" value="340" icon={<Truck />} color="warning" />
                <StatCard title="Orders Out for Delivery" value="125" icon={<Truck />} color="warning" />
                <StatCard title="Delivered Orders" value="448,500" icon={<CheckCircle />} color="success" />
                <StatCard title="Cancelled Orders" value="1,902" icon={<XOctagon />} color="danger" />
                <StatCard title="Returned Orders" value="531" icon={<XOctagon />} color="danger" />
            </div>

            <h3 className="panel-title" style={{ marginTop: '2rem' }}>Revenue Overview</h3>
            <div className="grid-cards">
                <StatCard title="Total Platform Revenue" value="₹4.5Cr" icon={<DollarSign />} color="success" />
                <StatCard title="Today's Revenue" value="₹2.4L" icon={<DollarSign />} color="success" trend="↑ 8%" />
                <StatCard title="Weekly Revenue" value="₹18.5L" icon={<TrendingUp />} color="success" />
                <StatCard title="Monthly Revenue" value="₹85.2L" icon={<TrendingUp />} color="success" />
            </div>

            <h3 className="panel-title" style={{ marginTop: '2rem' }}>Revenue Trends (Last 7 Days)</h3>
            <div className="panel" style={{ height: '300px', marginBottom: '2rem' }}>
                <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={revenueData} margin={{ top: 10, right: 30, left: -20, bottom: 0 }}>
                        <defs>
                            <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor="#10b981" stopOpacity={0.8} />
                                <stop offset="95%" stopColor="#10b981" stopOpacity={0} />
                            </linearGradient>
                        </defs>
                        <XAxis dataKey="name" stroke="var(--text-secondary)" fontSize={12} tickLine={false} axisLine={false} />
                        <YAxis stroke="var(--text-secondary)" fontSize={12} tickLine={false} axisLine={false} tickFormatter={(value) => `₹${value / 1000}k`} />
                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--border-light)" />
                        <Tooltip
                            contentStyle={{ backgroundColor: 'var(--bg-secondary)', borderColor: 'var(--border-light)', borderRadius: 'var(--radius-md)' }}
                            itemStyle={{ color: 'var(--text-primary)' }}
                        />
                        <Area type="monotone" dataKey="revenue" stroke="#10b981" strokeWidth={3} fillOpacity={1} fill="url(#colorRevenue)" />
                    </AreaChart>
                </ResponsiveContainer>
            </div>

            <div className="grid-2-cols" style={{ marginTop: '2rem' }}>
                <div className="panel">
                    <h3 className="panel-title">Payments & Payouts</h3>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                        <div className="info-row">
                            <span className="info-label">Pending Customer Payments</span>
                            <span className="info-value">₹45,200 <span className="status-badge status-warning" style={{ marginLeft: '10px' }}>124 Orders</span></span>
                        </div>
                        <div className="info-row">
                            <span className="info-label">Successful Payments</span>
                            <span className="info-value">₹8,45,000 <span className="status-badge status-success" style={{ marginLeft: '10px' }}>Today</span></span>
                        </div>
                        <div className="info-row">
                            <span className="info-label">Failed Payments</span>
                            <span className="info-value">₹12,400 <span className="status-badge status-danger" style={{ marginLeft: '10px' }}>34 Orders</span></span>
                        </div>
                        <div className="info-row">
                            <span className="info-label">Pending DP Payouts</span>
                            <span className="info-value">₹1,24,000 <span className="status-badge status-warning" style={{ marginLeft: '10px' }}>Processing</span></span>
                        </div>
                    </div>
                </div>

                <div className="panel">
                    <h3 className="panel-title">Operational Alerts</h3>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                        <div className="info-row" style={{ alignItems: 'center' }}>
                            <span className="info-label" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                <Clock size={16} color="var(--accent-danger)" /> Complaints Pending
                            </span>
                            <span className="info-value">
                                <span className="status-badge status-danger">45 Critical</span>
                            </span>
                        </div>
                        <div className="info-row" style={{ alignItems: 'center' }}>
                            <span className="info-label" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                <ShieldAlert size={16} color="var(--accent-warning)" /> Partners Pending Auth
                            </span>
                            <span className="info-value">
                                <span className="status-badge status-warning">134 Profiles</span>
                            </span>
                        </div>
                        <div className="info-row" style={{ alignItems: 'center' }}>
                            <span className="info-label" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                <AlertTriangle size={16} color="var(--accent-danger)" /> Business Pending Payments
                            </span>
                            <span className="info-value">
                                <span className="status-badge status-danger">12 Accounts Overdue</span>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
