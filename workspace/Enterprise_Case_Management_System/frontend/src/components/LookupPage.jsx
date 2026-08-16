import {useState} from "react";
export default function LookupPage({title,subtitle,placeholder,getRecord}){
 const[id,setId]=useState(""); const[record,setRecord]=useState(null); const[error,setError]=useState("");
 async function search(){try{setError("");setRecord(await getRecord(id.trim()))}catch(e){setRecord(null);setError(e.message)}}
 return <section><div className="page-header"><h1>{title}</h1><p>{subtitle}</p></div><div className="card"><div className="lookup"><input value={id} onChange={e=>setId(e.target.value)} placeholder={placeholder}/><button onClick={search}>Search</button></div>{error&&<div className="error">{error}</div>}{record&&<pre>{JSON.stringify(record,null,2)}</pre>}</div></section>
}