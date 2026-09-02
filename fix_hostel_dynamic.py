import re

with open('lib/screens/hostel_edit_screen.dart', 'r') as f:
    c = f.read()

# Add a list of strings to track dropdown values for allocatedFor
c = c.replace('List<TextEditingController> _allocatedControllers = [TextEditingController()];', 'List<String?> _allocatedSelections = [null];')
c = c.replace('_allocatedControllers.addAll(list.map((c) => TextEditingController(text: c.toString())));', '_allocatedSelections.addAll(list.map((c) => c.toString()));\n      if (_allocatedSelections.isEmpty) _allocatedSelections = [null];')

# Note: getting rid of the initial dummy if list is populated:
c = c.replace('if (item[\'allocatedFor\'] != null) {', '''if (item['allocatedFor'] != null) {
      _allocatedSelections.clear();''')

# In save
c = c.replace('"allocatedFor": getValues(_allocatedControllers),', '"allocatedFor": _allocatedSelections.where((v) => v != null).toList(),')

# Replace the UI call for allocatedFor
ui_replacement = """
                  _buildLabel("Allocated For"),
                  ...List.generate(_allocatedSelections.length, (index) {
                    return _buildGradientDropdown(
                      value: _allocatedSelections[index],
                      hint: "Select year",
                      items: const ["B.Tech 1st", "B.Tech 2nd", "B.Tech 3rd", "B.Tech 4th", "M.Tech 1st", "M.Tech 2nd", "PhD"],
                      onChanged: (val) {
                        setState(() {
                          _allocatedSelections[index] = val;
                        });
                      },
                    );
                  }),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _allocatedSelections.add(null);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                        margin: const EdgeInsets.only(bottom: 16, top: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5D5F5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black87),
                        ),
                        child: const Text("+ Add Year", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
"""

c = re.sub(r'_buildDynamicListSection\("Allocated For", "Allocated for", _allocatedControllers\),', ui_replacement, c)

# dispose controller cleanup
c = c.replace('for (var c in _allocatedControllers) { c.dispose(); }\n', '')

with open('lib/screens/hostel_edit_screen.dart', 'w') as f:
    f.write(c)

