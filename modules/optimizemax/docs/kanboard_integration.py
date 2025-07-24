#!/usr/bin/env python3
# 2025-07-23 15:15:00

import json
import requests
from typing import Dict, List, Optional
import sys

class KanboardClient:
    def __init__(self, url: str, token: str = None, username: str = None, password: str = None):
        self.url = url
        self.token = token
        self.username = username
        self.password = password
        self.headers = {'Content-Type': 'application/json'}
        
    def _make_request(self, method: str, params: Dict = None) -> Dict:
        """Make a JSON-RPC request to Kanboard"""
        payload = {
            "jsonrpc": "2.0",
            "method": method,
            "id": 1
        }
        
        if params:
            payload["params"] = params
            
        # Try token authentication first
        if self.token and method != "getAllProjects":
            if "params" not in payload:
                payload["params"] = {}
            payload["params"]["api_token"] = self.token
            
        auth = None
        if self.username and self.password:
            auth = (self.username, self.password)
            
        try:
            response = requests.post(
                self.url,
                json=payload,
                headers=self.headers,
                auth=auth,
                timeout=10
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            return {"error": str(e)}
            
    def test_connection(self) -> bool:
        """Test if we can connect to Kanboard"""
        result = self._make_request("getVersion")
        return "result" in result
        
    def get_all_projects(self) -> List[Dict]:
        """Get all projects"""
        result = self._make_request("getAllProjects")
        return result.get("result", [])
        
    def create_project(self, name: str, description: str = "") -> Optional[int]:
        """Create a new project"""
        params = {
            "name": name,
            "description": description
        }
        result = self._make_request("createProject", params)
        return result.get("result")
        
    def create_task(self, project_id: int, title: str, description: str = "", 
                   priority: int = 0, column_id: int = None) -> Optional[int]:
        """Create a new task"""
        params = {
            "project_id": project_id,
            "title": title,
            "description": description,
            "priority": priority
        }
        if column_id:
            params["column_id"] = column_id
            
        result = self._make_request("createTask", params)
        return result.get("result")
        
    def get_columns(self, project_id: int) -> List[Dict]:
        """Get columns for a project"""
        params = {"project_id": project_id}
        result = self._make_request("getColumns", params)
        return result.get("result", [])


def main():
    # Kanboard URL
    url = "http://192.168.178.188/jsonrpc.php"
    
    # Try different authentication methods
    print("Testing Kanboard connection...")
    
    # Test with tokens from credentials vault
    tokens = [
        "91cc77c33521efdb0a6cc74f3436012c76d6ed76839f9913a7771320be2d",
        "66caba29825f37883f59c04ce9fd50b0d043ffe9fb198d264eb02882065e"
    ]
    
    client = None
    for token in tokens:
        test_client = KanboardClient(url, token=token)
        if test_client.test_connection():
            print(f"✓ Connected with API token")
            client = test_client
            break
            
    if not client:
        # Try basic auth
        test_client = KanboardClient(url, username="admin", password="admin")
        if test_client.test_connection():
            print("✓ Connected with basic auth")
            client = test_client
            
    if not client:
        print("✗ Could not connect to Kanboard")
        print("\nPossible issues:")
        print("1. API tokens may have been rotated")
        print("2. Admin password has been changed from default")
        print("3. Kanboard service may not be running")
        print("\nPlease check the Kanboard instance at http://192.168.178.188")
        return
        
    # Get existing projects
    print("\nFetching existing projects...")
    projects = client.get_all_projects()
    
    if isinstance(projects, list):
        print(f"Found {len(projects)} projects:")
        for p in projects:
            print(f"  - {p.get('name')} (ID: {p.get('id')})")
            
        # Check if OptimizeMax exists
        optimize_max_id = None
        for p in projects:
            if p.get('name') == 'OptimizeMax':
                optimize_max_id = p.get('id')
                print(f"\n✓ OptimizeMax project already exists (ID: {optimize_max_id})")
                break
                
        if not optimize_max_id:
            # Create OptimizeMax project
            print("\nCreating OptimizeMax project...")
            optimize_max_id = client.create_project(
                "OptimizeMax",
                "AI-powered cost optimization system for Claude Code"
            )
            if optimize_max_id:
                print(f"✓ Created OptimizeMax project (ID: {optimize_max_id})")
            else:
                print("✗ Failed to create project")
                return
                
        # Get columns for the project
        columns = client.get_columns(optimize_max_id)
        first_column_id = columns[0]['id'] if columns else None
        
        # Define tasks with priorities (0=None, 1=Low, 2=Medium, 3=High)
        tasks = [
            {
                "title": "UserPromptSubmit Hook für additionalContext implementieren",
                "description": "Implementierung eines Hook-Systems für die Erweiterung von User-Prompts mit zusätzlichem Kontext",
                "priority": 3  # High
            },
            {
                "title": "Tool Confirmation System mit canUseTool Callback einrichten",
                "description": "System zur Bestätigung von Tool-Nutzung mit Callback-Mechanismus implementieren",
                "priority": 2  # Medium
            },
            {
                "title": "OptimizeMax GitHub Repository erstellen",
                "description": "Neues GitHub Repository für OptimizeMax anlegen und Grundstruktur einrichten",
                "priority": 2  # Medium
            },
            {
                "title": "Claude Code SDK Integration (TypeScript) entwickeln",
                "description": "TypeScript SDK für die Integration mit Claude Code entwickeln",
                "priority": 3  # High
            },
            {
                "title": "Kostenoptimierungs-Dashboard mit Echtzeit-Tracking",
                "description": "Dashboard zur Visualisierung und Tracking von API-Kosten in Echtzeit",
                "priority": 2  # Medium
            },
            {
                "title": "Multi-Model Orchestration System implementieren",
                "description": "System zur intelligenten Orchestrierung verschiedener AI-Modelle basierend auf Aufgabentyp",
                "priority": 2  # Medium
            },
            {
                "title": "Projekt-Mapping und Auto-Discovery System",
                "description": "Automatisches System zur Erkennung und Mapping von Projekt-Beziehungen",
                "priority": 1  # Low
            },
            {
                "title": "Integration Tests und Performance-Benchmarks",
                "description": "Umfassende Test-Suite und Performance-Benchmarks für OptimizeMax",
                "priority": 1  # Low
            }
        ]
        
        # Create tasks
        print(f"\nCreating tasks in OptimizeMax project...")
        created_count = 0
        for task in tasks:
            task_id = client.create_task(
                optimize_max_id,
                task["title"],
                task["description"],
                task["priority"],
                first_column_id
            )
            if task_id:
                priority_name = {0: "None", 1: "Low", 2: "Medium", 3: "High"}[task["priority"]]
                print(f"✓ Created task: {task['title']} (Priority: {priority_name})")
                created_count += 1
            else:
                print(f"✗ Failed to create task: {task['title']}")
                
        print(f"\n✓ Successfully created {created_count}/{len(tasks)} tasks")
        print(f"\nView your project at: http://192.168.178.188/?controller=BoardViewController&action=show&project_id={optimize_max_id}")
        
    else:
        print("✗ Could not fetch projects")


if __name__ == "__main__":
    main()