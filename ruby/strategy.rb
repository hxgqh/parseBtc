strategy = {
    'interval' => 600, #单位是秒，只对轮询信息有效

    'strategy1' => {
        'collect' => {
           'ip_list' => ['192.168.1.1','192.168.2.1-100','192.168.3-10.2-10']
        },

        'set' => {  #对于一下设置项，只有当需要设置的时候才设置，否则删除其所在的行
           'ip_list' => ['192.168.1.1','192.168.2.1-100','192.168.3-10.2-10'],
           'gateway' => '10.1.1.1',
           'web_port' => '8001',
           'primary_dns' => '8.8.8.8',
           'secondary_dns' => '4.4.4.4',
           'ports' => '8433,8443',
           'server_addresses' => '10.1.2.1,10.1.2.2',
           'userpass' => '"Testminer."&"A"&"B"&":123,"&"Testminer."A"&"B"&":123'
        }
    },

    'strategy2' => {
        'collect' => {

        },

        'set' => {

        }
    },

    'strategy3' => {
        'collect' => {

        },

        'set' => {

        }
    },
}