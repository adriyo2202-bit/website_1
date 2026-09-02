import re

# Fest
with open('lib/screens/fest_edit_screen.dart', 'r') as f:
    c = f.read()
c = c.replace("_selectedMonth = item['month'];", '''_selectedMonth = const ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"].contains(item['month']) ? item['month'] : null;''')
with open('lib/screens/fest_edit_screen.dart', 'w') as f:
    f.write(c)

# Hostel
with open('lib/screens/hostel_edit_screen.dart', 'r') as f:
    c = f.read()
c = c.replace("_selectedHostelType = item['hostelType'];", '''_selectedHostelType = const ["Boys", "Girls", "Co-Ed"].contains(item['hostelType']) ? item['hostelType'] : null;''')

c = c.replace('''if (item['allocatedFor'] != null) {
      _allocatedSelections.clear();
      List<dynamic> list = item['allocatedFor'];
      _allocatedSelections.addAll(list.map((c) => c.toString()));
      if (_allocatedSelections.isEmpty) _allocatedSelections = [null];
    }''', '''if (item['allocatedFor'] != null) {
      _allocatedSelections.clear();
      List<dynamic> list = item['allocatedFor'];
      final valid = const ["B.Tech 1st", "B.Tech 2nd", "B.Tech 3rd", "B.Tech 4th", "M.Tech 1st", "M.Tech 2nd", "PhD"];
      _allocatedSelections.addAll(list.map((c) => valid.contains(c.toString()) ? c.toString() : null));
      if (_allocatedSelections.isEmpty) _allocatedSelections = [null];
    }''')
with open('lib/screens/hostel_edit_screen.dart', 'w') as f:
    f.write(c)

# Room
with open('lib/screens/room_edit_screen.dart', 'r') as f:
    c = f.read()
c = c.replace("_selectedRoomType = widget.defaultRoomType;", '''_selectedRoomType = const ["ClassRoom", "Office"].contains(widget.defaultRoomType) ? widget.defaultRoomType : null;''')
with open('lib/screens/room_edit_screen.dart', 'w') as f:
    f.write(c)

# Faculty
with open('lib/screens/faculty_edit_screen.dart', 'r') as f:
    c = f.read()
c = c.replace("_selectedPosition = item['position'];", '''_selectedPosition = const ["Assistant Professor", "Associate Professor", "Professor"].contains(item['position']) ? item['position'] : null;''')
with open('lib/screens/faculty_edit_screen.dart', 'w') as f:
    f.write(c)
