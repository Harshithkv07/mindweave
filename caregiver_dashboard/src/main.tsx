import React, { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";
import "./styles.css";

const API = "http://127.0.0.1:8000";
type Session = {id:number; game_type:string; difficulty:number; accuracy:number; response_time:number; mistakes:number; started_at:string};

async function api(path:string, token:string) {
  const r = await fetch(API + path, {headers:{Authorization:`Bearer ${token}`}});
  if (!r.ok) throw new Error(await r.text());
  return r.json();
}

function App() {
  const [token,setToken] = useState("");
  const [email,setEmail] = useState("caregiver@example.com");
  const [password,setPassword] = useState("password123");
  const [patientId,setPatientId] = useState(1);
  const [sessions,setSessions] = useState<Session[]>([]);
  const [profile,setProfile] = useState<any>(null);
  const [insight,setInsight] = useState("");
  const [alerts,setAlerts] = useState<any[]>([]);
  const [error,setError] = useState("");

  async function login(e:React.FormEvent) {
    e.preventDefault(); setError("");
    try {
      const r=await fetch(API+"/auth/login",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({email,password})});
      if(!r.ok) throw new Error(await r.text());
      const d=await r.json(); setToken(d.access_token);
    } catch(x:any){setError(x.message)}
  }

  async function load() {
    if(!token) return;
    try {
      const [s,p,i,a]=await Promise.all([
        api(`/patients/${patientId}/sessions`,token),
        api(`/patients/${patientId}/profile`,token),
        api(`/patients/${patientId}/insights`,token),
        api(`/patients/${patientId}/alerts`,token)
      ]);
      setSessions(s); setProfile(p); setInsight(i.insight); setAlerts(a);
    } catch(x:any){setError(x.message)}
  }
  useEffect(()=>{load()},[token,patientId]);

  if(!token) return <main className="center"><form className="card login" onSubmit={login}>
    <h1>MindWeave</h1><p>Caregiver Dashboard</p>
    <input value={email} onChange={e=>setEmail(e.target.value)} placeholder="Email"/>
    <input type="password" value={password} onChange={e=>setPassword(e.target.value)} placeholder="Password"/>
    <button>Sign in</button>{error && <small>{error}</small>}
  </form></main>;

  const chart=sessions.slice().reverse().map((s,i)=>({name:i+1,score:Math.round(s.accuracy*100)}));
  return <main>
    <header><div><h1>MindWeave</h1><span>Caregiver Dashboard</span></div><button onClick={()=>setToken("")}>Sign out</button></header>
    <section className="grid">
      <div className="card"><h2>Personal profile</h2>{profile?.profile && Object.entries(profile.profile).map(([k,v])=><div className="metric" key={k}><span>{k}</span><b>{String(v)}%</b></div>)}</div>
      <div className="card"><h2>AI insight</h2><p>{insight}</p><p className="muted">{profile?.baseline_note}</p></div>
    </section>
    <section className="card"><h2>Performance trend</h2><div className="chart"><ResponsiveContainer width="100%" height="100%"><LineChart data={chart}><CartesianGrid strokeDasharray="3 3"/><XAxis dataKey="name"/><YAxis domain={[0,100]}/><Tooltip/><Line type="monotone" dataKey="score"/></LineChart></ResponsiveContainer></div></section>
    <section className="card"><h2>Alerts</h2>{alerts.length===0?<p>No attention alerts.</p>:alerts.map(a=><div className="alert" key={a.id}><b>{a.severity}</b> — {a.message}</div>)}</section>
    <section className="card"><h2>Activity history</h2><table><thead><tr><th>Game</th><th>Difficulty</th><th>Accuracy</th><th>Response</th><th>Mistakes</th></tr></thead><tbody>{sessions.map(s=><tr key={s.id}><td>{s.game_type}</td><td>{s.difficulty}</td><td>{Math.round(s.accuracy*100)}%</td><td>{s.response_time.toFixed(1)}s</td><td>{s.mistakes}</td></tr>)}</tbody></table></section>
  </main>
}
createRoot(document.getElementById("root")!).render(<App/>);
