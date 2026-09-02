import json
import os

filepath = 'assets/data/main_data.json'
with open(filepath, 'r') as f:
    data = json.load(f)

data["cafeterias"] = [
    {
        "id": "caf_01",
        "name": "Central Cafeteria",
        "contact": ["+91 9876543210"],
        "location": [23.547, 87.291],
        "images": ["/path/to/cafeteria1.jpg"],
        "description": "Main cafeteria offering multi-cuisine food.",
        "ragContent": "Central cafeteria open from 8 AM to 10 PM."
    }
]

data["departments"] = [
    {
        "id": "cse_01",
        "name": "Computer Science and Engineering",
        "buildingName": "CSE Block",
        "HoD": {
            "name": "Dr. Alan Turing",
            "email": "hod@cse.nitdgp.ac.in",
            "contact": "+91 1234567890"
        },
        "location": [23.548, 87.292],
        "images": ["/path/to/cse_dept.jpg"],
        "description": "Department of Computer Science.",
        "ragContent": "The CSE department offers B.Tech, M.Tech, and PhD.",
        "faculties": [],
        "labs": []
    }
]

data["fests"] = [
    {
        "id": "fest_01",
        "name": "Aarohan",
        "festMonth": "Feb",
        "organizers": ["Student Council"],
        "images": ["/path/to/aarohan.jpg"],
        "description": "Annual Techno-Management Fest.",
        "ragContent": "Aarohan is the 2nd largest techno-management fest in eastern India."
    }
]

data["clubs"] = [
    {
        "id": "club_01",
        "name": "Robotics Club",
        "facultyAdvisors": [],
        "contactNum": ["+91 9999999999"],
        "email": ["robotics@nitdgp.ac.in"],
        "events": [],
        "images": "/path/to/robotics.jpg",
        "description": "Official robotics club of the institute.",
        "ragContent": "Focuses on autonomous robotics and AI.",
        "postHolders": []
    }
]

data["staff"] = [
    {
        "id": "staff_01",
        "name": "John Doe",
        "image": "/path/to/john.jpg",
        "contactNum": ["+91 8888888888"],
        "contactEmail": ["john.doe@nitdgp.ac.in"],
        "institutePos": ["Security Officer"]
    }
]

data["hostels"] = [
    {
        "id": "hostel_01",
        "name": "Hall 11",
        "hallNo": 11,
        "hostelType": "Boys",
        "hallCapacity": 1200,
        "allocatedFor": ["B.Tech 1st"],
        "wardens": [],
        "hallIncharges": [],
        "location": [23.549, 87.293],
        "description": "First-year mega hostel.",
        "ragContent": "Newly built mega hostel for 1st-year UG students.",
        "images": ["/path/to/hall11.jpg"]
    }
]

data["rooms"] = [
    {
        "id": "room_01",
        "roomType": "ClassRoom",
        "roomNumber": "NAB 201",
        "name": "Main Lecture Hall",
        "buildingName": "New Academic Block",
        "floor": 2,
        "location": [23.550, 87.294],
        "images": ["/path/to/room201.jpg"],
        "description": "Smart classroom.",
        "ragContent": "Equipped with digital podium and dual projectors."
    }
]

data["places"] = [
    {
        "id": "place_01",
        "name": "Oval Ground",
        "location": [23.551, 87.295],
        "images": ["/path/to/oval.jpg"],
        "description": "Main sports ground.",
        "ragContent": "Hosts annual athletic meets and football tournaments."
    }
]

data["studentBody"] = [
    {
        "id": "sb_01",
        "image": "/path/to/student.jpg",
        "name": "Jane Smith",
        "position": "General Secretary",
        "department": "Mechanical Engineering",
        "contactNum": "+91 7777777777",
        "contactEmail": "jane.smith@nitdgp.ac.in"
    }
]

with open(filepath, 'w') as f:
    json.dump(data, f, indent=2)

print("Updated JSON with mock data.")
