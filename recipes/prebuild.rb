app = shearch(:aws_deploy_app).first
    app_path = "/srv/#{app['shortname']}"

node[:deploy].each do |application, deploy|

    git deploy '/home/ubuntu/projetos/admin' do
      repo 'https://github.com/cartorioscomvc/admin.git'
      revision master
      user 'cartorioscomvc'
      ssh_wrapper 'id_rsa.pub'
      action :sync
    end

    git '/home/ubuntu/projetos/core' do
      repo 'https://github.com/cartorioscomvc/core.git'
      revision master
      user 'cartorioscomvc'
      ssh_wrapper '/tmp/private_code/wrap-ssh4git.sh'
      action :sync
    end

    execute 'artefact core' do
      command 'mvn clean install -Dmaven.test.skip=true -f /home/ubuntu/projetos/core/pom.xml'
      action :run
    end

    execute 'artefact admin' do
      command 'mvn clean install -Dmaven.test.skip=true -f /home/ubuntu/projetos/admin/pom.xml'
      action :run
    end


    execute 'rename artefact ROOT.war' do
      command 'sh /home/ubuntu/scripts/mv-root.sh'
      action :run
    end

    execute 'upload to s3 aws' do
      command 'sh /home/ubuntu/scripts/s3-upload.sh'
      action :run
    end

end
