// c 2025-05-19
// m 2025-05-19

const string  pluginColor = "\\$FAA";
const string  pluginIcon  = Icons::Kenney::SoundOff;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
const float   scale       = UI::GetScale();
Sound@[]      sounds;

void Main() {
    AddSoundsFromFolder("GameData/Menu/Media/audio/Sound",           "Menu");
    AddSoundsFromFolder("GameData/Vehicles/Cars/CommonMedia/Audio",  "Common");
    AddSoundsFromFolder("GameData/Vehicles/Cars/CarDesert/Audio",    "CarDesert");
    AddSoundsFromFolder("GameData/Vehicles/Cars/CarRally/Audio",     "CarRally");
    AddSoundsFromFolder("GameData/Vehicles/Cars/CarSnow/Audio",      "CarSnow");
    AddSoundsFromFolder("GameData/Vehicles/Cars/CarSport/Audio",     "CarSport");
    AddSoundsFromFolder("GameData/Vehicles/Media/Audio/Sound",       "Vehicles");
    AddSoundsFromFolder("GameData/Vehicles/Media/Audio/Sound/Water", "Water");

    sounds.SortAsc();
}

void AddSoundsFromFolder(const string &in folderName, const string &in sourceName) {
    CSystemFidsFolder@ Folder = Fids::GetGameFolder(folderName);
    if (Folder is null) {
        return;
    }

    for (uint i = 0; i < Folder.Leaves.Length; i++) {
        CSystemFidFile@ File = Folder.Leaves[i];
        if (File !is null) {
            CPlugSound@ PlugSound = cast<CPlugSound>(File.Nod);
            if (PlugSound !is null) {
                auto sound = Sound(PlugSound, sourceName);
                if (sound.name.Length > 0 and sound.name != "empty") {
                    sounds.InsertLast(sound);
                }
            }
        }
    }
}

[SettingsTab name="Sounds" icon="Kenney::SoundOn" order=0]
void RenderSounds() {
    if (UI::BeginTable("##table-sliders", 5, UI::TableFlags::RowBg)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(vec3(), 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("folder", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("mute", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("restore", UI::TableColumnFlags::WidthFixed);
        UI::TableSetupColumn("slider", UI::TableColumnFlags::WidthStretch);
        UI::TableHeadersRow();

        UI::ListClipper clipper(sounds.Length);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                Sound@ sound = sounds[i];

                UI::BeginDisabled(sound.sound is null);

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::AlignTextToFramePadding();
                UI::Text(sound.name);

                UI::TableNextColumn();
                UI::AlignTextToFramePadding();
                UI::Text("\\$666" + sound.folder);

                UI::TableNextColumn();
                UI::BeginDisabled(sound.muted);
                if (UI::Button("mute##" + i)) {
                    sound.Mute();
                }
                UI::EndDisabled();

                UI::TableNextColumn();
                UI::BeginDisabled(sound.restored);
                if (UI::Button("restore##" + i)) {
                    sound.Restore();
                }
                UI::EndDisabled();

                UI::TableNextColumn();
                UI::SetNextItemWidth(UI::GetContentRegionAvail().x / scale);
                sound.volume = UI::SliderFloat("##slider" + i, sound.volume, -60.0f, 20.0f);

                UI::EndDisabled();
            }
        }

        UI::PopStyleColor();
        UI::EndTable();
    }
}

[SettingsTab name="Debug" icon="Bug" order=1]
void RenderDebug() {
    UI::SeparatorText("App.AudioPort.Sources");

    CAudioPort@ AudioPort = GetApp().AudioPort;
    for (uint i = 0; i < AudioPort.Sources.Length; i++) {
        CAudioSource@ Source = AudioPort.Sources[i];
        if (Source !is null and Source.PlugSound !is null) {
            auto sound = Sound(Source.PlugSound, "AudioPort");
            if (sound.name.Length > 0 and sound.name != "empty") {
                UI::Selectable(tostring(i) + " " + sound.name, Source.IsPlaying);
            }
        }
    }
}
