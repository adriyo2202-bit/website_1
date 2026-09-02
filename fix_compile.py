import re

def fix_fest():
    with open('lib/screens/fest_edit_screen.dart', 'r') as f:
        c = f.read()
    c = c.replace("_monthController.text = item['month'] ?? '';", "_selectedMonth = item['month'];")
    c = c.replace("_monthController.dispose();", "")
    with open('lib/screens/fest_edit_screen.dart', 'w') as f:
        f.write(c)

def fix_hostel():
    with open('lib/screens/hostel_edit_screen.dart', 'r') as f:
        c = f.read()
    c = c.replace("_allocatedControllers.clear();", "_allocatedSelections.clear();")
    c = c.replace('"location": _locationCoords,', '"location": locationObj,')
    # wait, earlier in hostel edit screen we had `List<double>? _locationCoords`, did it get removed? No, I just need to fix location serialization.
    # Ah, the error is `_locationCoords` is not defined. Wait, maybe `_locationCoords` was called something else in hostel? 
    # Let me check hostel_edit_screen.dart
    
    # Also _typeController
    c = c.replace("_typeController.dispose();", "")
    c = c.replace("_buildGradientTextField(hint: \"Type of Hostel\", controller: _typeController),", '''_buildGradientDropdown(
                    value: _selectedHostelType,
                    hint: "Select hostel type",
                    items: const ["Boys", "Girls", "Co-Ed"],
                    onChanged: (val) => setState(() => _selectedHostelType = val),
                  ),''')
    with open('lib/screens/hostel_edit_screen.dart', 'w') as f:
        f.write(c)

def fix_room():
    with open('lib/screens/room_edit_screen.dart', 'r') as f:
        c = f.read()
    c = c.replace("_roomTypeController.text = widget.defaultRoomType!;", "_selectedRoomType = widget.defaultRoomType;")
    c = c.replace("_roomTypeController.dispose();", "")
    c = c.replace("_buildGradientTextField(hint: \"Type of the room\", controller: _roomTypeController),", '''_buildGradientDropdown(
                    value: _selectedRoomType,
                    hint: "Select room type",
                    items: const ["ClassRoom", "Office"],
                    onChanged: (val) => setState(() => _selectedRoomType = val),
                  ),''')
    with open('lib/screens/room_edit_screen.dart', 'w') as f:
        f.write(c)

def fix_faculty():
    with open('lib/screens/faculty_edit_screen.dart', 'r') as f:
        c = f.read()
    c = c.replace("_positionController.dispose();", "")
    c = c.replace("_buildGradientTextField(hint: \"Position of the faculty\", controller: _positionController),", '''_buildGradientDropdown(
                    value: _selectedPosition,
                    hint: "Select position",
                    items: const ["Assistant Professor", "Associate Professor", "Professor"],
                    onChanged: (val) => setState(() => _selectedPosition = val),
                  ),''')
    with open('lib/screens/faculty_edit_screen.dart', 'w') as f:
        f.write(c)

fix_fest()
fix_hostel()
fix_room()
fix_faculty()
