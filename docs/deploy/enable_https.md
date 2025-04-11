Before reading this document, you should read [docs/deploy/deploy_on_CentOS10.md](/docs/deploy/deploy_on_CentOS10.md) first.

## Support "https" for web

### Way 1: Use a third-party service such as CloudFlare (recommended)

This is the most convenient way.

If you use CloudFlare SSL/TLS encryption default mode `Flexible`, you can see "https" has already been supported.

### Way 2: Implement support for "https" yourself

First, confirm that http://your-domain.com is accessible and there are no problems.

Then, if you are using CloudFlare, please do:
    - Click `SSL/TLS` -> `Configure`.
    - Choose `Full` for *Custom SSL/TLS*.
    - Click `Save`.

#### Use `acme.sh` to auto-renew SSL certificate

```shell
firewall-cmd --add-port=443/tcp

yum install cronie -y
systemctl enable crond.service
systemctl start crond.service

yum install socat -y

curl https://get.acme.sh | sh -s email=your_email@example.com # Change the email to administrator's email

exit
ssh root@the_server_ip

acme.sh --set-default-ca --server letsencrypt
acme.sh --issue -d your-domain.com -d www.your-domain.com -w /srv/markdown-resume-blog/public # Replace the "your-domain.com" with your actual domain name.
```

If you get an error message `your-domain.com: Invalid status. Verification error details: 2606:4700:3030::ac43:9171: Invalid response from http://your-domain.com/.well-known/acme-challenge/pffchpZxkQd3vm5TcBO3L-ifnGEAzsbzl7OmUDxg_H4: 404`,
that means your web server or nginx are not running properly. Read [docs/deploy/deploy_on_CentOS10.md](/docs/deploy/deploy_on_CentOS10.md) to fix it. Then you can run it again.

```shell
mkdir /etc/nginx/ssl_key_cert
acme.sh --install-cert -d your-domain.com --key-file /etc/nginx/ssl_key_cert/key.pem --fullchain-file /etc/nginx/ssl_key_cert/cert.pem --reloadcmd "service nginx force-reload"
```

Copy the contents of [blog_nginx_https.conf](/docs/deploy/blog_nginx_https.conf) to `/etc/nginx/conf.d/blog_nginx.conf` and replace `your-domain.com` to your real domain.

```shell
systemctl restart nginx 
```

Visit https://www.your-domain.com, https://your-domain.com, http://www.your-domain.com or http://your-domain.com to test it.
