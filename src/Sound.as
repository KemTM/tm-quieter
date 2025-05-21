// c 2025-05-19
// m 2025-05-20

class Sound {
    string      folder;
    string      name;
    CPlugSound@ sound;

    private float _defaultVolume = 0.0f;
    float get_defaultVolume() {
        return _defaultVolume;
    }

    bool get_muted() {
        return volume == -100.0f;
    }

    bool get_restored() {
        return volume == _defaultVolume;
    }

    string get_uid() {
        return folder + "-" + name;
    }

    float volume {
        get {
            return sound !is null ? sound.VolumedB : 0.0f;
        }

        set {
            if (sound !is null) {
                sound.VolumedB = value;

                if (value != defaultVolume) {
                    choices[uid] = value;
                }
            }
        }
    }

    Sound(CPlugSound@ sound, const string &in folder, const string &in name = "") {
        @this.sound = sound;
        this.folder = folder;

        _defaultVolume = volume;

        if (name.Length > 0) {
            this.name = name;
        } else {
            CSystemFidFile@ File = GetFidFromNod(sound);
            if (File !is null) {
                this.name = File.ShortFileName;
            }
        }
    }

    ~Sound() {
        if (volume != _defaultVolume) {
            Restore(true);
        }
    }

    int opCmp(Sound@ other) {
        if (other is null or name < other.name) {
            return -1;
        }

        if (other.name < name) {
            return 1;
        }

        return 0;
    }

    void Mute() {
        volume = -100.0f;
    }

    void Restore(bool destruct = false) {
        volume = _defaultVolume;

        if (!destruct and choices.HasKey(uid)) {
            choices.Remove(uid);
        }
    }
}
