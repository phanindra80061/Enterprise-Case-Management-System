import { Routes, Route } from "react-router-dom";
import Sidebar from "./components/Sidebar";
import Dashboard from "./pages/Dashboard";
import Customers from "./pages/Customers";
import Employees from "./pages/Employees";
import Cases from "./pages/Cases";
import Assignments from "./pages/Assignments";
import Notes from "./pages/Notes";
import Attachments from "./pages/Attachments";
import Audit from "./pages/Audit";

export default function App(){
  return <div className="app"><Sidebar/><main className="main"><Routes>
    <Route path="/" element={<Dashboard/>}/>
    <Route path="/customers" element={<Customers/>}/>
    <Route path="/employees" element={<Employees/>}/>
    <Route path="/cases" element={<Cases/>}/>
    <Route path="/assignments" element={<Assignments/>}/>
    <Route path="/notes" element={<Notes/>}/>
    <Route path="/attachments" element={<Attachments/>}/>
    <Route path="/audit" element={<Audit/>}/>
  </Routes></main></div>;
}