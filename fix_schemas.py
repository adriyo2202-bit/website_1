import re
import glob

def replacer(filepath, old, new):
    with open(filepath, 'r') as f:
        content = f.read()
    if old in content:
        content = content.replace(old, new)
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

# Fest
replacer('lib/screens/fest_edit_screen.dart', '"month":', '"festMonth":')

# Place, Cafeteria, Laboratory
for f in ['place_edit_screen.dart', 'cafeteria_edit_screen.dart', 'laboratory_edit_screen.dart', 'item_edit_screen.dart']:
    replacer(f'lib/screens/{f}', '"locationCord":', '"location":')

# Staff
replacer('lib/screens/staff_edit_screen.dart', '"images": _localImagePath != null ? [_localImagePath] : [],', '"image": _localImagePath ?? "",')
replacer('lib/screens/staff_edit_screen.dart', '"contacts":', '"contactNum":')
replacer('lib/screens/staff_edit_screen.dart', '"emails":', '"contactEmail":')
replacer('lib/screens/staff_edit_screen.dart', '"institutePositions":', '"institutePos":')

# Hostel (fix location)
replacer('lib/screens/hostel_edit_screen.dart', '''Map<String, dynamic>? locationObj;
    if (_locationCoords != null) {
      locationObj = {
        'lat': _locationCoords![0],
        'lng': _locationCoords![1]
      };
    }''', '')
replacer('lib/screens/hostel_edit_screen.dart', '"location": locationObj,', '"location": _locationCoords,')

# Room (fix location)
replacer('lib/screens/room_edit_screen.dart', '''Map<String, dynamic>? locationObj;
    if (_locationCoords != null) {
      locationObj = {
        'lat': _locationCoords![0],
        'lng': _locationCoords![1]
      };
    }''', '')
replacer('lib/screens/room_edit_screen.dart', '"location": locationObj,', '"location": _locationCoords,')

# Warden (Faculty)
replacer('lib/screens/warden_edit_screen.dart', '"images": _localImagePath != null ? [_localImagePath] : [],', '"image": _localImagePath ?? "",')
replacer('lib/screens/warden_edit_screen.dart', '"contacts":', '"contactNumber":')
replacer('lib/screens/warden_edit_screen.dart', '"emails":', '"email":')

# Faculty
replacer('lib/screens/faculty_edit_screen.dart', '"images": _localImagePath != null ? [_localImagePath] : [],', '"image": _localImagePath ?? "",')
replacer('lib/screens/faculty_edit_screen.dart', '"contacts":', '"contactNumber":')
replacer('lib/screens/faculty_edit_screen.dart', '"emails":', '"email":')
replacer('lib/screens/faculty_edit_screen.dart', '"domains":', '"interestedDomain":')

# Department
replacer('lib/screens/department_edit_screen.dart', '"locationCord": _locationCoords,', '"location": _locationCoords,')
replacer('lib/screens/department_edit_screen.dart', '''"hodName": _hodNameController.text.trim(),
      "hodContact": _hodContactController.text.trim(),
      "hodEmail": _hodEmailController.text.trim(),''', '''"HoD": {
        "name": _hodNameController.text.trim(),
        "email": _hodEmailController.text.trim(),
        "contact": _hodContactController.text.trim(),
      },''')

# Laboratory (fix floor from string to int)
replacer('lib/screens/laboratory_edit_screen.dart', '"floor": _floorController.text.trim(),', '"floor": int.tryParse(_floorController.text.trim()) ?? 0,')

print("All done!")
