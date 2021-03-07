%define prefix /usr/local/nginx
Name:           openresty
Version:        1.19.3.1
Release:        1%{?dist}
Summary:        openresty编译

Group:			nn
License:        GPL
URL:            https://gybyt.cn
Source0:        https://openresty.org/download/%{name}-%{version}.tar.gz
Source1:        nginx.conf
Source2:        nginx.service
Source3:		default.conf

BuildRequires:  perl pcre-devel openssl-devel gcc gd  libxslt-devel libxml2-devel geoip-devel libatomic_ops-devel libstdc++
Requires:       pcre openssl cmake gcc libxml2 libxslt gd geoip libstdc++

# 描述
%description
openresty by nn

# 编译前准备
%prep
%setup -q

# 编译
%build
CFLAGS="-fPIC" ./configure --prefix=/usr/local/nginx --sbin-path=/usr/sbin/nginx --conf-path=/usr/local/nginx/nginx.conf --pid-path=/var/run/nginx.pid --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --lock-path=/var/lock/nginx.lock --with-luajit --with-http_gunzip_module --with-pcre --with-pcre-jit --with-http_perl_module --with-ld-opt="-Wl,-E" --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_addition_module --with-http_xslt_module --with-http_image_filter_module --with-http_geoip_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-select_module --with-poll_module --with-file-aio --with-http_degradation_module --with-libatomic --http-client-body-temp-path=/var/tmp/nginx/client_body --http-proxy-temp-path=/var/tmp/nginx/proxy --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi --http-scgi-temp-path=/var/tmp/nginx/scgi -j6
make -j6

# 安装
%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=%{buildroot}
%{__install} -p -D -m 0644 %{SOURCE1} %{buildroot}%{prefix}/nginx.conf
%{__install} -p -D -m 0644 %{SOURCE2} %{buildroot}%{_usr}/lib/systemd/system/nginx.service
%{__install} -p -D -m 0644 %{SOURCE3} %{buildroot}%{prefix}/conf.d/default.conf

# 安装前准备
%pre
if [ $1 == 1 ]; then
        id nginx &> /dev/null
        if [ $? -ne 0 ]
        then
        /usr/sbin/useradd -r nginx -s /sbin/nologin 2> /dev/null
        fi
fi

# 安装后操作
%post
if [ $1 == 1 ]; then
        mkdir -p /var/tmp/nginx/proxy
        mkdir -p /var/tmp/nginx/client_body
        mkdir -p /var/log/nginx
fi

# 卸载前准备
%preun
if [ $1 == 0 ]; then
        %if 0%{?use_systemd}
                if [ -f /usr/lib/systemd/system/nginx.service ]
                %systemd_preun nginx.service
                fi
        %endif
        count=`ps -ef |grep nginx |grep -v "grep" |wc -l`
        if [ $count -gt 0 ]; then
        nginx -s stop
        fi
fi

# 卸载后步骤
%postun
if [ $1 == 0 ]; then
        systemctl disable nginx
        rm -rf /var/tmp/nginx/proxy
        rm -rf /var/tmp/nginx/client_body
        rm -rf /usr/lib/systemd/system/nginx.service
        rm -rf /var/tmp/nginx
        rm -rf /var/log/nginx
        rm -rf /usr/local/lib64/perl5/auto/nginx
        rm -rf /usr/local/nginx
        userdel nginx
        systemctl daemon-reload
fi

# 文件列表
%files
%defattr(-,root,root,0755)
%{_usr}/lib64/perl5/perllocal.pod
%{_usr}/local/lib64/perl5/auto/nginx/.packlist
%{_usr}/local/lib64/perl5/auto/nginx/nginx.bs
%{_usr}/local/lib64/perl5/auto/nginx/nginx.so
%{_usr}/local/lib64/perl5/nginx.pm
%{_usr}/local/share/man/man3/nginx.3pm
%{_sbindir}/nginx
%{_usr}/local/nginx/
%{_usr}/lib/systemd/system/nginx.service
%config(noreplace) %{_usr}/local/nginx/nginx.conf
%config(noreplace) %{_usr}/local/nginx/conf.d/*.conf
# 文档
%doc

# 更改日志
%changelog

