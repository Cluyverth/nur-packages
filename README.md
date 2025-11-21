# 📦 cluyverth-nix-pkgs

**Custom Nix packages, derivations, and overlays maintained by @cluyverth.**

This repository functions as a **NUR (Nix User Repository)** channel, providing packages that are either not yet in the official `nixpkgs` repository or are custom-tailored versions.

---

## 🎯 Repository Scope

The packages here are primarily maintained by **Cluyverth** for **personal use** on NixOS.

However, the repository is open to **community contributions**. Any package submitted via a Pull Request will be maintained as part of this collection, provided it meets the Nix standards and quality checks.

## ✨ Highlights

* **Personalized Packages:** Packages specifically tailored and configured for Cluyverth's daily usage environment.
* **Community Contributions:** Welcoming packages and updates via Pull Requests from the community.

## 🚀 How to Use

To install packages from this repository, you need to include it in your Nix configuration, typically as a NUR channel.

### Using with NUR (Recommended)

```nix
{ config, pkgs, ... }:

let
  # 1. Import the NUR tool
  nur = builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz";

  # 2. Load the packages from Cluyverth's repository (cluyverth-nix-pkgs)
  cluyverthPkgs = import "${nur}/repos/cluyverth/cluyverth-nix-pkgs" { inherit pkgs; };

in
{
  # ... (rest of your configuration)

  environment.systemPackages = with pkgs // cluyverthPkgs; [
    # Your package is now available!
    helium
    # other packages...
  ];
}
```

### Alternative: Using as a Direct Overlay

```nix
nixpkgs.overlays = [
  (final: prev: {
    # Imports packages from this repository (username is cluyverth)
    cluyverth-pkgs = import (
      builtins.fetchTarball "https://github.com/cluyverth/cluyverth-nix-pkgs/archive/main.tar.gz"
    ) { pkgs = prev; };
    
    # Expose the Helium package directly
    helium = final.cluyverth-pkgs.helium;
  })
];
```

## 📦 Available Packages

| Package Name | Description | Status |
| :--- | :--- | :--- |
| `helium` | Helium Browser: Internet without interruptions. | ✅ V0.6.7.1 |
| `[NEXT_PACKAGE]` | (Add other packages here) | ⚙️ In Development |

---

## 🤝 Contribution

Feel free to open an Issue or submit a Pull Request. Contributions are highly encouraged and welcome!

* Clone the repository.
* Create a new feature branch (`git checkout -b feature/my-new-package`).
* Commit your changes.
* Open a Pull Request.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.