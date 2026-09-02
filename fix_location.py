import re

def fix_room():
    with open('lib/screens/room_edit_screen.dart', 'r') as f:
        c = f.read()
    c = c.replace('Map<String, double>? locationObj;', 'List<double>? _locationCoords;')
    c = c.replace('locationObj = {"lat": 23.5478, "lng": 87.2931};', '_locationCoords = [23.5478, 87.2931];')
    # wait, the string literal replacement might fail if the spacing is different.
    # Let me just use regex
    c = re.sub(r'Map<String, double>\? locationObj;.*?\n\s*if \(_selectedLocation != null\) {\n\s*locationObj = {"lat": 23.5478, "lng": 87.2931};\n\s*}', 
               '''List<double>? _locationCoords;
    if (_selectedLocation != null) {
      _locationCoords = [23.5478, 87.2931];
    }''', c, flags=re.DOTALL)
    with open('lib/screens/room_edit_screen.dart', 'w') as f:
        f.write(c)

def fix_hostel():
    with open('lib/screens/hostel_edit_screen.dart', 'r') as f:
        c = f.read()
    c = re.sub(r'Map<String, double>\? locationObj;.*?\n\s*if \(_selectedLocation != null\) {\n\s*locationObj = {"lat": 23.5478, "lng": 87.2931};\n\s*}', 
               '''List<double>? _locationCoords;
    if (_selectedLocation != null) {
      _locationCoords = [23.5478, 87.2931];
    }''', c, flags=re.DOTALL)
    
    # Also I noticed I incorrectly replaced locationObj back to locationObj in fix_compile.py for hostel!
    c = c.replace('"location": locationObj,', '"location": _locationCoords,')
    with open('lib/screens/hostel_edit_screen.dart', 'w') as f:
        f.write(c)

fix_room()
fix_hostel()
