Name:       harbour-reminders
Summary:    Recurring reminder application
Version:    0.1
Release:    1
Group:      Applications/Editors
License:    GPL-2
URL:        https://github.com/amtep/reminders
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  desktop-file-utils
BuildRequires:  qt5-qmake
Requires: libsailfishapp-launcher

%description
This application allows the user to schedule daily reminders for
recurring tasks. Its main feature compared to calendar or to-do
applications is that it can reschedule the reminder X days after
the last time the task was done, rather than X days after the last
time the task was scheduled. This makes it well suited for scheduling
cleaning and maintenance tasks, especially housework.

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5
make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/%{name}.desktop
%{_datadir}/%{name}/*
%{_datadir}/icons/hicolor/86x86/apps/%{name}.png
