import React, { useState, useEffect } from 'react';
import { MoreHorizontal, Edit2, MapPin, Truck, ArrowLeft, RefreshCw } from 'lucide-react';

const Orders = () => {
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedOrder, setSelectedOrder] = useState(null);

    const fetchOrders = async (showLoading = true) => {
        if (showLoading) setLoading(true);
        try {
            const res = await fetch('http://localhost:3000/api/users/orders');
            if (res.ok) {
                const data = await res.json();
                setOrders(data);
            }
        } catch (error) {
            console.error('Error fetching orders:', error);
        } finally {
            if (showLoading) setLoading(false);
        }
    };

    useEffect(() => {
        fetchOrders(true);
        const interval = setInterval(() => fetchOrders(false), 5000);
        return () => clearInterval(interval);
    }, []);

    const getStatusBadge = (statusName) => {
        let badgeClass = "status-neutral";
        if (statusName === 'Delivered') badgeClass = "status-success";
        else if (statusName === 'In Transit' || statusName === 'Picked Up') badgeClass = "status-warning";
        else if (statusName === 'Assigned') badgeClass = "status-info";
        else if (statusName === 'Pending') badgeClass = "status-neutral";
        return <span className={`status-badge ${badgeClass}`}>{statusName || 'Pending'}</span>;
    };

    const formatDate = (dateString) => {
        if (!dateString) return 'N/A';
        const d = new Date(dateString);
        return d.toLocaleDateString() + ' ' + d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    };

    if (selectedOrder) {
        const order = selectedOrder;
        const parcelInfo = order.parcels && order.parcels.length > 0 ? order.parcels[0] : null;

        return (
            <div className="fade-in">
                <div className="details-header">
                    <button className="back-btn" onClick={() => setSelectedOrder(null)}>
                        <ArrowLeft size={20} />
                    </button>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <h1 className="page-title">Order Info: #{order.order_id}</h1>
                        {getStatusBadge(order.status_name)}
                    </div>
                </div>

                <div className="grid-2-cols">
                    <div className="panel">
                        <h3 className="panel-title" style={{ color: 'var(--accent-primary)' }}>Sender Information</h3>
                        <div className="info-row"><span className="info-label">Name</span><span className="info-value">{order.sender_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Phone</span><span className="info-value">{order.sender_phone || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Address</span><span className="info-value">{order.sender_address || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">City</span><span className="info-value">{order.sender_city || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">State</span><span className="info-value">{order.sender_state || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Pincode</span><span className="info-value">{order.sender_pincode || 'N/A'}</span></div>
                    </div>

                    <div className="panel">
                        <h3 className="panel-title" style={{ color: 'var(--accent-success)' }}>Receiver Information</h3>
                        <div className="info-row"><span className="info-label">Name</span><span className="info-value">{order.receiver_name || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Phone</span><span className="info-value">{order.receiver_phone || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Address</span><span className="info-value">{order.receiver_address || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">City</span><span className="info-value">{order.receiver_city || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">State</span><span className="info-value">{order.receiver_state || 'N/A'}</span></div>
                        <div className="info-row"><span className="info-label">Pincode</span><span className="info-value">{order.receiver_pincode || 'N/A'}</span></div>
                    </div>

                    <div className="panel" style={{ gridColumn: 'span 2' }}>
                        <h3 className="panel-title">Order Details</h3>
                        <div className="grid-3-cols" style={{ marginBottom: 0 }}>
                            <div>
                                <h4 style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Parcel Information</h4>
                                <div className="info-row"><span className="info-label">Parcel Type</span><span className="info-value">{parcelInfo?.parcel_type || 'N/A'}</span></div>
                                <div className="info-row"><span className="info-label">Parcel Size</span><span className="info-value">{parcelInfo?.parcel_size || 'N/A'}</span></div>
                                <div className="info-row"><span className="info-label">Weight</span><span className="info-value">{parcelInfo?.weight ? parcelInfo.weight + ' kg' : 'N/A'}</span></div>
                                <div className="info-row"><span className="info-label">Instructions</span><span className="info-value">{order.special_instruction || 'None'}</span></div>
                            </div>
                            <div>
                                <h4 style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Delivery Information</h4>
                                <div className="info-row"><span className="info-label">Assigned Rider</span><span className="info-value">{order.dp_first_name ? `${order.dp_first_name} ${order.dp_last_name || ''}` : 'Not Assigned'}</span></div>
                                <div className="info-row"><span className="info-label">Vehicle</span><span className="info-value">{order.vehicle_name || 'Not Available'}</span></div>
                                <div className="info-row"><span className="info-label">Amount</span><span className="info-value">₹{order.order_amount || '0'}</span></div>
                                <div className="info-row"><span className="info-label">Distance</span><span className="info-value">{order.distance_km ? order.distance_km + ' km' : 'N/A'}</span></div>
                            </div>
                            <div>
                                <h4 style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '0.5rem' }}>Status Timeline</h4>
                                <div className="info-row"><span className="info-label">Order Placed</span><span className="info-value">{formatDate(order.created_at)}</span></div>
                                <div className="info-row"><span className="info-label">Current Status</span><span className="info-value" style={{ fontWeight: 'bold' }}>{order.status_name || 'Pending'}</span></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="fade-in">
            <div className="page-header">
                <div>
                    <h1 className="page-title">Orders</h1>
                    <p className="page-subtitle">Track, manage and monitor live delivery progress.</p>
                </div>
                <button className="primary-btn" onClick={fetchOrders} style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <RefreshCw size={16} /> Refresh
                </button>
            </div>

            <div className="table-container">
                <div className="table-header">
                    <span className="table-title">Live Orders Tracking</span>
                    <div style={{ display: 'flex', gap: '0.5rem' }}>
                        <button className="primary-btn" style={{ padding: '0.4rem 0.8rem', background: 'var(--bg-primary)', border: '1px solid var(--border-light)' }}>Filter</button>
                        <button className="primary-btn" style={{ padding: '0.4rem 0.8rem' }}>Export CSV</button>
                    </div>
                </div>
                {loading ? (
                    <div style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-secondary)' }}>Loading orders...</div>
                ) : (
                    <table>
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Sender</th>
                                <th>Receiver</th>
                                <th>Route</th>
                                <th>Parcel</th>
                                <th>Amount</th>
                                <th>Status</th>
                                <th>Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {orders.length === 0 ? (
                                <tr>
                                    <td colSpan="9" style={{ textAlign: 'center', padding: '2rem', color: 'var(--text-secondary)' }}>
                                        No orders found
                                    </td>
                                </tr>
                            ) : (
                                orders.map((order) => {
                                    const parcelInfo = order.parcels && order.parcels.length > 0 ? order.parcels[0] : null;
                                    
                                    return (
                                        <tr key={order.order_id}>
                                            <td><span style={{ color: 'var(--accent-primary)', fontWeight: '600' }}>#{String(order.order_id).substring(0, 8)}</span></td>
                                            <td>
                                                <div style={{ fontSize: '0.85rem', fontWeight: '500' }}>{order.sender_name || 'N/A'}</div>
                                                <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>+91 {order.sender_phone}</div>
                                            </td>
                                            <td>
                                                <div style={{ fontSize: '0.85rem', fontWeight: '500' }}>{order.receiver_name || 'N/A'}</div>
                                                <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>+91 {order.receiver_phone}</div>
                                            </td>
                                            <td style={{ fontSize: '0.75rem' }}>
                                                <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                                                    <MapPin size={12} color="var(--accent-success)" /> 
                                                    <span title={order.sender_city} style={{maxWidth: '60px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace:'nowrap'}}>
                                                        {order.sender_city || 'N/A'}
                                                    </span>
                                                </div>
                                                <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '2px' }}>
                                                    <Truck size={12} color="var(--accent-primary)" /> 
                                                    <span title={order.receiver_city} style={{maxWidth: '60px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace:'nowrap'}}>
                                                        {order.receiver_city || 'N/A'}
                                                    </span>
                                                </div>
                                            </td>
                                            <td>
                                                <div style={{ fontSize: '0.85rem', fontWeight: '500' }}>{parcelInfo?.parcel_type || 'N/A'}</div>
                                                <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{parcelInfo?.parcel_size || 'N/A'}</div>
                                            </td>
                                            <td><span style={{ fontWeight: '600' }}>₹{order.order_amount ? Number(order.order_amount).toFixed(0) : '0'}</span></td>
                                            <td>{getStatusBadge(order.status_name)}</td>
                                            <td style={{ fontSize: '0.85rem' }}>
                                                <div>{new Date(order.created_at).toLocaleDateString()}</div>
                                                <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{new Date(order.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</div>
                                            </td>
                                            <td>
                                                <div className="td-actions">
                                                    <button className="btn-icon" onClick={() => setSelectedOrder(order)} title="View Details"><MoreHorizontal size={16} /></button>
                                                </div>
                                            </td>
                                        </tr>
                                    );
                                })
                            )}
                        </tbody>
                    </table>
                )}
            </div>
        </div>
    );
};

export default Orders;
