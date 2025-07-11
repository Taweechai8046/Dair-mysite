function saveNote() {
  const input = document.getElementById("noteInput");
  const note = input.value.trim();
  if (note !== "") {
    const notes = JSON.parse(localStorage.getItem("notes")) || [];
    notes.push(note);
    localStorage.setItem("notes", JSON.stringify(notes));
    input.value = "";
    showNotes();
  }
}

function showNotes() {
  const notes = JSON.parse(localStorage.getItem("notes")) || [];
  const notesList = document.getElementById("notesList");
  notesList.innerHTML = "";

  notes.forEach((note, index) => {
    const noteDiv = document.createElement("div");
    noteDiv.className = "note";
    noteDiv.innerHTML = `
      ${note}
      <br><br>
      <button onclick="deleteNote(${index})">ลบ</button>
    `;
    notesList.appendChild(noteDiv);
  });
}

function deleteNote(index) {
  const notes = JSON.parse(localStorage.getItem("notes")) || [];
  notes.splice(index, 1);
  localStorage.setItem("notes", JSON.stringify(notes));
  showNotes();
}

showNotes(); // โหลดบันทึกเมื่อเปิดหน้าเว็บ
