import {useState} from "react";
import {api} from "../services/api";
const blank={customerId:"",firstName:"",lastName:"",email:"",phone:"",dateOfBirth:"",customerStatus:"Active"};
export default function Customers(){
 const[form,setForm]=useState(blank); const[lookupId,setLookupId]=useState(""); const[record,setRecord]=useState(null); const[message,setMessage]=useState("");
 const change=e=>setForm({...form,[e.target.name]:e.target.value});
 async function search(){try{setRecord(await api.getCustomer(lookupId));setMessage("")}catch(e){setRecord(null);setMessage(e.message)}}
 async function create(){try{const data=await api.createCustomer({...form,customerId:Number(form.customerId)});setMessage(data.message||"Customer created.")}catch(e){setMessage(e.message)}}
 async function update(){try{const{customerId,dateOfBirth,...payload}=form;const data=await api.updateCustomer(customerId,payload);setMessage(data.message||"Customer updated.")}catch(e){setMessage(e.message)}}
 async function remove(){try{const data=await api.deleteCustomer(form.customerId||lookupId);setRecord(null);setMessage(data.message||"Customer deleted.")}catch(e){setMessage(e.message)}}
 return <section><div className="page-header"><h1>Customers</h1><p>Basic customer CRUD against OpenEdge.</p></div>
 <div className="card"><h3>Find Customer</h3><div className="lookup"><input value={lookupId} onChange={e=>setLookupId(e.target.value)} placeholder="Customer ID"/><button onClick={search}>Search</button></div>{record&&<pre>{JSON.stringify(record,null,2)}</pre>}</div>
 <div className="card"><h3>Create / Update Customer</h3><div className="form-grid">
 {["customerId","firstName","lastName","email","phone","dateOfBirth"].map(n=><input key={n} name={n} value={form[n]} onChange={change} placeholder={n}/>)}
 <select name="customerStatus" value={form.customerStatus} onChange={change}><option>Active</option><option>Inactive</option></select></div>
 <div className="actions"><button onClick={create}>Create</button><button className="secondary" onClick={update}>Update</button><button className="danger" onClick={remove}>Delete</button></div>{message&&<div className="message">{message}</div>}</div></section>
}