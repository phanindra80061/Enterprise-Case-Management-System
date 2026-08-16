async function request(path,options={}){
 const response=await fetch(`/api${path}`,{...options,headers:{"Content-Type":"application/json",...(options.headers||{})}});
 const type=response.headers.get("content-type")||"";
 const data=type.includes("application/json")?await response.json():{message:await response.text()};
 if(!response.ok) throw new Error(data.message||`HTTP ${response.status}`);
 return data;
}
export const api={
 getCustomer:id=>request(`/customers/${id}`),
 createCustomer:body=>request("/customers",{method:"POST",body:JSON.stringify(body)}),
 updateCustomer:(id,body)=>request(`/customers/${id}`,{method:"PUT",body:JSON.stringify(body)}),
 deleteCustomer:id=>request(`/customers/${id}`,{method:"DELETE"}),
 getEmployee:id=>request(`/employees/${id}`),
 getCase:id=>request(`/cases/${id}`),
 getAssignment:id=>request(`/assignments/${id}`),
 getNote:id=>request(`/notes/${id}`),
 getAttachment:id=>request(`/attachments/${id}`),
 getAudit:id=>request(`/audit/${id}`)
};