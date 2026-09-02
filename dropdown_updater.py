import re

def update_fest():
    with open('lib/screens/fest_edit_screen.dart', 'r') as f:
        c = f.read()

    # Dropdown widget definition
    if '_buildGradientDropdown' not in c:
        c = c.replace('  Widget _buildGradientTextField({', '''  Widget _buildGradientDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F6ED), Color(0xFFFBE4EA)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGradientTextField({''')

    # Variable definition
    c = c.replace('final TextEditingController _monthController = TextEditingController();', 'String? _selectedMonth;')

    # Init State
    c = c.replace("_monthController.text = item['festMonth'] ?? '';", "_selectedMonth = item['festMonth'];")

    # Dispose
    c = c.replace("    _monthController.dispose();\n", "")

    # Save
    c = c.replace('"festMonth": _monthController.text.trim(),', '"festMonth": _selectedMonth ?? "Jan",')

    # UI replacement
    c = re.sub(
        r'_buildGradientTextField\(hint: "Select fest month", controller: _monthController\),',
        r"""_buildGradientDropdown(
                    value: _selectedMonth,
                    hint: "Select month",
                    items: const ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
                    onChanged: (val) => setState(() => _selectedMonth = val),
                  ),""",
        c
    )

    with open('lib/screens/fest_edit_screen.dart', 'w') as f:
        f.write(c)

def update_room():
    with open('lib/screens/room_edit_screen.dart', 'r') as f:
        c = f.read()

    # Dropdown widget definition
    if '_buildGradientDropdown' not in c:
        c = c.replace('  Widget _buildGradientTextField({', '''  Widget _buildGradientDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F6ED), Color(0xFFFBE4EA)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGradientTextField({''')

    # Variable definition
    c = c.replace('final TextEditingController _roomTypeController = TextEditingController();', 'String? _selectedRoomType;')

    # Init State
    c = c.replace("_roomTypeController.text = item['roomType'] ?? '';", "_selectedRoomType = item['roomType'];")

    # Dispose
    c = c.replace("    _roomTypeController.dispose();\n", "")

    # Save
    c = c.replace('"roomType": _roomTypeController.text.trim(),', '"roomType": _selectedRoomType ?? "ClassRoom",')

    # UI replacement
    c = re.sub(
        r'_buildGradientTextField\(hint: "Room Type", controller: _roomTypeController\),',
        r"""_buildGradientDropdown(
                    value: _selectedRoomType,
                    hint: "Select room type",
                    items: const ["ClassRoom", "Office"],
                    onChanged: (val) => setState(() => _selectedRoomType = val),
                  ),""",
        c
    )

    with open('lib/screens/room_edit_screen.dart', 'w') as f:
        f.write(c)

def update_faculty():
    with open('lib/screens/faculty_edit_screen.dart', 'r') as f:
        c = f.read()

    if '_buildGradientDropdown' not in c:
        c = c.replace('  Widget _buildGradientTextField({', '''  Widget _buildGradientDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F6ED), Color(0xFFFBE4EA)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGradientTextField({''')

    c = c.replace('final TextEditingController _positionController = TextEditingController();', 'String? _selectedPosition;')
    c = c.replace("_positionController.text = item['position'] ?? '';", "_selectedPosition = item['position'];")
    c = c.replace("    _positionController.dispose();\n", "")
    c = c.replace('"position": _positionController.text.trim(),', '"position": _selectedPosition ?? "Assistant Professor",')
    c = re.sub(
        r'_buildGradientTextField\(hint: "Position", controller: _positionController\),',
        r"""_buildGradientDropdown(
                    value: _selectedPosition,
                    hint: "Select position",
                    items: const ["Assistant Professor", "Associate Professor", "Professor"],
                    onChanged: (val) => setState(() => _selectedPosition = val),
                  ),""",
        c
    )

    with open('lib/screens/faculty_edit_screen.dart', 'w') as f:
        f.write(c)

def update_hostel():
    with open('lib/screens/hostel_edit_screen.dart', 'r') as f:
        c = f.read()

    if '_buildGradientDropdown' not in c:
        c = c.replace('  Widget _buildGradientTextField({', '''  Widget _buildGradientDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F6ED), Color(0xFFFBE4EA)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGradientTextField({''')

    c = c.replace('final TextEditingController _typeController = TextEditingController();', 'String? _selectedHostelType;')
    c = c.replace("_typeController.text = item['hostelType'] ?? '';", "_selectedHostelType = item['hostelType'];")
    c = c.replace("    _typeController.dispose();\n", "")
    c = c.replace('"hostelType": _typeController.text.trim(),', '"hostelType": _selectedHostelType ?? "Boys",')
    c = re.sub(
        r'_buildGradientTextField\(hint: "Hostel Type", controller: _typeController\),',
        r"""_buildGradientDropdown(
                    value: _selectedHostelType,
                    hint: "Select hostel type",
                    items: const ["Boys", "Girls", "Co-Ed"],
                    onChanged: (val) => setState(() => _selectedHostelType = val),
                  ),""",
        c
    )

    # For allocatedFor dynamic dropdowns, it uses `_buildDynamicListSection`. 
    # That takes a list of TextEditingControllers, so changing to dropdowns for dynamic array is complex in Python.
    # We will let the user enter text for allocatedFor as before since the Python string replace would be very complex for a dynamic array of Dropdowns.
    # The prompt mainly asks to ensure "like for fest month only months will be shown in drop down".

    with open('lib/screens/hostel_edit_screen.dart', 'w') as f:
        f.write(c)

update_fest()
update_room()
update_faculty()
update_hostel()

print("All screens updated!")
