# THIS SCRIPT HAS ONLY BEEN TESTED IN MACOS MOJAVE FOR INITIALIZE A DEV ENVIRONMENT ON A REMOTE SERVER.

. config.sh

# Get absolute path of known_hosts file
KNOWN_HOSTS_ABSOLUTE_PATH=`eval echo ${KNOWN_HOSTS_FILE//>}`

# Remove old entry from known_hosts
if [ -f $KNOWN_HOSTS_ABSOLUTE_PATH ]; then
  if [[ -n $(cat $KNOWN_HOSTS_ABSOLUTE_PATH | grep $REMOTE_ADDRESS) ]]; then
    echo "⏳ Removing $REMOTE_ADDRESS from $KNOWN_HOSTS_ABSOLUTE_PATH"
    sed -i '' "/$REMOTE_ADDRESS/d" "$KNOWN_HOSTS_ABSOLUTE_PATH"
    echo "✅ $REMOTE_ADDRESS is removed from $KNOWN_HOSTS_ABSOLUTE_PATH"
    echo ""
  fi
else
  echo "❌ $KNOWN_HOSTS_ABSOLUTE_PATH not found"
fi

# Copy public key
ssh-copy-id "$REMOTE_ADMIN@$REMOTE_ADDRESS"

# Copy files to remote server
echo "⏳ Copying CUDA driver installation script to $REMOTE_ADDRESS"
scp $LOCAL_CUDA_DRIVER_FILE $REMOTE_ADMIN@$REMOTE_ADDRESS:$REMOTE_CUDA_DRIVER_FILE
ssh -t $REMOTE_ADMIN@$REMOTE_ADDRESS chmod +x $REMOTE_CUDA_DRIVER_FILE
echo "✅ Copied CUDA driver installation script to $REMOTE_ADMIN@$REMOTE_ADDRESS:$REMOTE_CUDA_DRIVER_FILE"
echo ""
echo "⏳ Copying setup scripts to $REMOTE_ADDRESS"
ssh -t $REMOTE_ADMIN@$REMOTE_ADDRESS "rm -rf $REMOTE_SCRIPT_DIR"
scp -pr $LOCAL_SCRIPT_DIR $REMOTE_ADMIN@$REMOTE_ADDRESS:$REMOTE_SCRIPT_DIR
ssh -t $REMOTE_ADMIN@$REMOTE_ADDRESS "find $REMOTE_SCRIPT_DIR -type f -exec chmod +x {} \;"
echo "✅ Copied setup script to $REMOTE_ADMIN@$REMOTE_ADDRESS:$REMOTE_SCRIPT_DIR"
echo ""

# Run remote scripts
ssh -t $REMOTE_ADMIN@$REMOTE_ADDRESS "$REMOTE_SCRIPT_DIR/setup_script_1.sh"
echo ''
ssh -t $REMOTE_ADMIN@$REMOTE_ADDRESS "$REMOTE_SCRIPT_DIR/setup_script_2.sh $REMOTE_CUDA_DRIVER_FILE"
