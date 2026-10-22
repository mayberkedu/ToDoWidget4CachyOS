.pragma library

// English is the source language and fallback. Each widget owns its language
// setting, so changing one widget never changes Plasma or another widget.
var turkish = {
    "All": "Tümü",
    "To do": "Yapılacak",
    "Done": "Biten",
    "New task": "Yeni görev",
    "Add task": "Görev ekle",
    "Edit task": "Görevi düzenle",
    "Task text": "Görev metni",
    "Deadline": "Son tarih",
    "Choose date · optional": "Tarih seç · isteğe bağlı",
    "Choose a deadline": "Son tarih seç",
    "Priority": "Öncelik",
    "%1 priority": "%1 öncelik",
    "Green": "Yeşil",
    "Yellow": "Sarı",
    "Red": "Kırmızı",
    "Cancel": "Vazgeç",
    "Save": "Kaydet",
    "Edit": "Düzenle",
    "Delete": "Sil",
    "Clear completed": "Bitenleri temizle",
    "Right-click to add a task": "Görev eklemek için sağ tıkla",
    "No tasks in this view": "Bu görünümde görev yok",
    "Appearance & language…": "Görünüm ve dil…",
    "Appearance & language": "Görünüm ve dil",
    "Language": "Dil",
    "Glass color": "Cam rengi",
    "Choose a background color": "Arka plan rengini seç",
    "Tint / color blend": "Tint / renk karışımı",
    "Tint strength": "Tint yoğunluğu",
    "0% neutral glass, 100% your chosen color.": "%0 nötr cam, %100 seçtiğin renk.",
    "Background opacity": "Arka plan opaklığı",
    "0% transparent, 100% opaque. Task text stays fully visible.": "%0 saydam, %100 opak. Görev yazıları bu ayardan etkilenmez.",
    "Choose a glass color": "Cam rengini seç",
    "Previous month": "Önceki ay",
    "Next month": "Sonraki ay",
    "Today": "Bugün",
    "Clear date": "Tarihi kaldır",
    "Reopen": "Yeniden aç",
    "Complete": "Tamamla",
    "Overdue": "Gecikmiş",
    "Task options: %1": "Görev seçenekleri: %1",
    "1 task remaining": "1 görev kaldı",
    "%1 tasks remaining": "%1 görev kaldı",
    "Task text cannot be empty.": "Görev metni boş olamaz.",
    "Tasks can contain up to 240 characters.": "Görev en fazla 240 karakter olabilir.",
    "Choose a valid deadline.": "Geçerli bir son tarih seçin.",
    "Choose a valid priority.": "Geçerli bir öncelik seçin.",
    "Saved tasks could not be read. Your data has not been overwritten.": "Kayıtlı görevler okunamadı. Verilerinizin üzerine yazılmadı."
};

function text(language, source, values) {
    var result = language === "tr" && Object.prototype.hasOwnProperty.call(turkish, source)
        ? turkish[source] : source;
    if (values) {
        result = result.replace(/%(\d+)/g, function(match, index) {
            return Number(index) <= values.length ? String(values[Number(index) - 1]) : match;
        });
    }
    return result;
}

function localeName(language) {
    return language === "tr" ? "tr_TR" : "en_US";
}
